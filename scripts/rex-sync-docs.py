#!/usr/bin/env python3
"""Sync the Rex docs and generate lua-language-server stubs for the rex API.

Downloads the Lua and events references, captures the server API and action
list from the local `rex` CLI, and writes everything under
$XDG_DATA_HOME/rex (default ~/.local/share/rex):

  docs/   lua.md, events.md, llms-full.txt
  api/    api.json (rex api call help.all), actions.json (rex actions --json)
  types/  rex.lua, a ---@meta file for lua-language-server

Run it again after updating Rex.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

DOCS_URL = "https://www.superlogical.com/rex/docs"
DOC_PAGES = {
    "lua.md": "reference/lua.md",
    "events.md": "reference/events.md",
    "llms-full.txt": "llms-full.txt",
}

# lua.md documents most functions in prose, so these hints supply the types it
# doesn't spell out. Everything else is read from the docs and the server.

# Class names for the tables in a function's section, in order. None skips one.
TABLE_CLASSES = {
    "rex.bindings": ["RexBinding"],
    "rex.action": ["RexActionSpec"],
    "rex.layout": [None, "RexTerminalOptions"],
    "rex.host": ["RexHostSpec"],
    "rex.exec": ["RexExecOpts", "RexExecResult"],
    "rex.exec.start": ["RexExecStartOpts", "RexExecHandle"],
    "rex.every": ["RexTimer"],
}

PARAM_TYPES = {
    "key": "string",
    "action": "RexAction",
    "args": "table",
    "fn": "function",
    "target": "RexAction|function",
    "binding": "RexBinding",
    "name": "string",
    "filter": "table",
    "event": "RexEvent",
    "seconds": "number",
    "timeout": "number",
    "code": "integer",
    "label": "string",
    "method": "RexMethod",
    "creator": "string",
    "argv": "string[]",
    "value": "any",
    "text": "string",
    "level": '"debug"|"info"|"warn"|"error"',
    "message": "string",
    "ratio": "number",
    "a": "RexLayout",
    "b": "RexLayout",
    "flavor": "string",
    "data": "string",
    "signal": "string|integer",
}

PARAM_OVERRIDES = {
    "rex.bind.fn": "fun(ctx: RexContext, ev: { keybinding: string, prefix?: string[] }): boolean?",
    "rex.on.fn": "fun(ctx: RexContext, ev: RexEventData)",
    "rex.wait.filter": "table|fun(ev: RexEventData, ctx: RexContext): boolean",
    "rex.after.fn": "fun(ctx: RexContext)",
    "rex.every.fn": "fun(ctx: RexContext)",
    "rex.mode.options": "{ exclusive?: boolean }",
    "rex.unbind.spec": "{ mode: string }",
    "rex.bindings.filter": "{ key?: string, mode?: string, action?: string }",
    "rex.json.encode.opts": "{ indent?: boolean }",
    "rex.client.queue.name": "RexClientAction",
    "rex.layout.block.options": "RexTerminalOptions",
}

RETURNS = {
    "rex.unbind": ["integer"],
    "rex.bindings": ["RexBinding[]"],
    "rex.modes": ["{ name: string, exclusive: boolean, source: string }[]"],
    "rex.invoke": ["any", "string?"],
    "rex.call": ["table?", "string?"],
    "rex.block.call": ["table?", "string?"],
    "rex.layout.block": ["RexLayout"],
    "rex.layout.horizontal": ["RexLayout"],
    "rex.layout.vertical": ["RexLayout"],
    "rex.wait": ["RexEventData?", "RexContext|string"],
    "rex.servers": ["string[]"],
    "rex.server": ["{ session: table, block: table, call: function }"],
    "rex.exec": ["RexExecResult?", "string?"],
    "rex.exec.start": ["RexExecHandle?", "string?"],
    "rex.after": ["RexTimer"],
    "rex.every": ["RexTimer"],
    "rex.json.encode": ["string?", "string?"],
    "rex.json.decode": ["any", "string?"],
}

SCRIPT_VALUE_TYPES = {"rex.args": "table", "rex.session_id": "string", "rex.block_id": "string?"}

SCALARS = {"string": "string", "integer": "integer", "number": "number", "boolean": "boolean"}


def log(msg):
    print(f"rex-sync-docs: {msg}", file=sys.stderr)


def ident(*parts):
    words = [w for p in parts for w in re.split(r"[^A-Za-z0-9]+", p) if w]
    return "".join(w[:1].upper() + w[1:] for w in words)


def lit(value):
    return json.dumps(value)


def one_line(text):
    return " ".join((text or "").split())


def comment(text):
    return ["--- " + line if line.strip() else "---" for line in (text or "").strip().splitlines()]


def paren(t):
    return f"({t})" if "|" in t or t.startswith("fun(") else t


def union(types):
    return "|".join(dict.fromkeys(t for t in types if t)) or "any"


# --- Inputs ---------------------------------------------------------------


def load_docs(docs_dir, offline):
    docs = {}
    for name, page in DOC_PAGES.items():
        url = f"{DOCS_URL}/{page}"
        cached = docs_dir / name
        if not offline:
            # curl rather than urllib, so the system trust store and proxy apply.
            r = subprocess.run(["curl", "-fsSL", "--max-time", "30", url], capture_output=True, text=True)
            if r.returncode == 0:
                docs[name] = r.stdout
                continue
            log(f"could not fetch {url}: {r.stderr.strip()}")
        if cached.exists():
            log(f"using cached {cached}")
            docs[name] = cached.read_text()
        else:
            docs[name] = ""
    return docs


def rex_json(*args):
    out = subprocess.run(["rex", *args], check=True, capture_output=True, text=True).stdout
    return json.loads(out)


def load_actions():
    actions = {a["name"]: a for a in rex_json("actions", "--json")["actions"]}
    clients = rex_json("client", "list", "--json").get("clients", [])
    app = next((c for c in clients if c.get("info", {}).get("kind") == "app"), None)
    if app:
        for a in rex_json("-C", app["client_id"], "actions", "--json")["actions"]:
            actions.setdefault(a["name"], a)
    else:
        log("no Rex app is connected, so client actions such as pane.split are left out")
    return list(actions.values())


# --- JSON Schema to LuaLS -------------------------------------------------


class Schemas:
    def __init__(self):
        self.out = []
        self.names = set()
        self.anchors = {}

    def collect_anchors(self, node):
        if isinstance(node, dict):
            if isinstance(node.get("$anchor"), str):
                self.anchors["#" + node["$anchor"]] = ident("Rex", node["$anchor"])
            for v in node.values():
                self.collect_anchors(v)
        elif isinstance(node, list):
            for v in node:
                self.collect_anchors(v)

    def type(self, s, name, optional=()):
        if not isinstance(s, dict):
            return "any"
        if "$ref" in s:
            return self.anchors.get(s["$ref"], "table")
        if "enum" in s:
            return union(lit(v) for v in s["enum"] if v is not None)
        for key in ("anyOf", "oneOf"):
            if key in s:
                return union(self.type(sub, f"{name}{i + 1}") for i, sub in enumerate(s[key]))
        t = s.get("type")
        types = [x for x in (t if isinstance(t, list) else [t]) if isinstance(x, str) and x != "null"]
        parts = []
        for x in types or ["any"]:
            if x == "object":
                parts.append(self.object(s, name, optional))
            elif x == "array":
                parts.append(paren(self.type(s.get("items"), name + "Item")) + "[]")
            else:
                parts.append(SCALARS.get(x, "any"))
        return union(parts)

    def object(self, s, name, optional=()):
        props = s.get("properties")
        if not props:
            extra = s.get("additionalProperties")
            if isinstance(extra, dict):
                return f"table<string, {self.type(extra, name + 'Value')}>"
            return "table"
        if isinstance(s.get("$anchor"), str):
            name = self.anchors["#" + s["$anchor"]]
            if name in self.names:
                return name
        base, n = name, 2
        while name in self.names:
            name, n = f"{base}{n}", n + 1
        self.names.add(name)
        required = set(s.get("required", [])) - set(optional)
        lines = [""] + comment(s.get("description")) + [f"---@class {name}"]
        for key, prop in props.items():
            if not re.fullmatch(r"[A-Za-z_]\w*", key):
                continue
            opt = "" if key in required else "?"
            t = self.type(prop, name + ident(key))
            desc = one_line(prop.get("description") if isinstance(prop, dict) else "")
            lines.append(f"---@field {key}{opt} {t} {desc}".rstrip())
        self.out.extend(lines)
        return name


def has_required(schema, optional=()):
    return bool(set((schema or {}).get("required", [])) - set(optional))


def method_doc(m):
    lines = comment(m.get("description"))
    notes = m.get("validation_notes") or []
    if notes:
        lines += ["---"] + [f"--- - {one_line(n)}" for n in notes]
    if m.get("request_example"):
        lines += ["---", "--- ```json"] + comment(m["request_example"]) + ["--- ```"]
    return lines


def gen_api(api, actions, S):
    """Return (lines, overloads); overloads adds signatures to lua.md functions."""
    S.collect_anchors(api)
    lines = []
    overloads = {k: [] for k in ("rex.call", "rex.block.call", "rex.bind", "rex.invoke", "rex.client.queue")}

    methods = api.get("methods", [])
    lines += ["", "---@alias RexMethod"]
    lines += [f"---| {lit(m['name'])} # {one_line(m.get('description'))}" for m in methods]

    for m in methods:
        name = m["name"]
        session = name.startswith("session.")
        # rex.session.* fills in session_id when it is left out.
        optional = ("session_id",) if session else ()
        schema = m.get("input_schema") or {}
        args_t = S.type(schema, ident("Rex", name, "Args"), optional)
        result_t = S.type(m.get("output_schema"), ident("Rex", name, "Result"))
        q = "" if has_required(schema, optional) else "?"
        overloads["rex.call"].append(f"fun(method: {lit(name)}, args{q}: {args_t}): {paren(result_t)}?, string?")
        if session:
            lines += [""] + method_doc(m) + [
                f"---@param args{q} {args_t}",
                f"---@return {paren(result_t)}? result",
                "---@return string? err",
                f"function rex.session.{name[len('session.'):]}(args) end",
            ]

    for bt in api.get("block_types", []):
        creator = bt.get("creator")
        for m in bt.get("methods", []):
            base = ident("Rex", m.get("invoke", {}).get("method", f"{creator}.{m['name']}"))
            schema = m.get("args_schema") or {}
            args_t = S.type(schema, base + "Args")
            result_t = S.type(m.get("output_schema"), base + "Result")
            q = "" if has_required(schema) else "?"
            overloads["rex.block.call"].append(
                f"fun(creator: {lit(creator)}, method: {lit(m['name'])}, args{q}: {args_t}): {paren(result_t)}?, string?"
            )

    lines += ["", "---@alias RexAction"]
    lines += [f"---| {lit(a['name'])} # {one_line(a.get('title') or a.get('description'))}" for a in actions]
    lines += ["", "---@alias RexClientAction"]
    lines += [f"---| {lit(a['name'])}" for a in actions if a.get("kind") == "client"] or ["---| string"]

    for a in actions:
        schema = a.get("args")
        if not isinstance(schema, dict) or not schema.get("properties"):
            continue
        args_t = S.type(schema, ident("Rex", a["name"], "ActionArgs"))
        q = "" if has_required(schema) else "?"
        overloads["rex.bind"].append(f"fun(key: string, action: {lit(a['name'])}, args{q}: {args_t})")
        overloads["rex.invoke"].append(f"fun(name: {lit(a['name'])}, args{q}: {args_t}): any, string?")
        if a.get("kind") == "client":
            overloads["rex.client.queue"].append(f"fun(name: {lit(a['name'])}, args{q}: {args_t})")
    return lines, overloads


# --- Markdown -------------------------------------------------------------


def sections(md):
    md = re.sub(r"\A---\n.*?\n---\n", "", md, flags=re.S)
    out, fence = [], False
    current = {"title": "", "body": []}
    for line in md.splitlines():
        if line.startswith("```"):
            fence = not fence
        m = None if fence else re.match(r"^#{2,3} (.+)$", line)
        if m:
            out.append(current)
            current = {"title": m.group(1).strip(), "body": []}
        else:
            current["body"].append(line)
    out.append(current)
    return out


def tables(lines):
    def cells(row):
        return [c.strip() for c in row.strip().strip("|").split("|")]

    found, i = [], 0
    while i < len(lines):
        if lines[i].startswith("|") and i + 1 < len(lines) and re.match(r"^\|[\s:|-]+\|$", lines[i + 1]):
            header, rows, i = cells(lines[i]), [], i + 2
            while i < len(lines) and lines[i].startswith("|"):
                rows.append(cells(lines[i]))
                i += 1
            found.append((header, rows))
        else:
            i += 1
    return found


def ticks(cell):
    return re.findall(r"`([^`]+)`", cell)


def parse_params(text):
    """Parse `key, action[, args]` into [(name, optional)]."""
    params, depth, tok = [], 0, ""
    for ch in text + ",":
        if ch in "[],":
            if tok.strip():
                params.append((tok.strip(), depth > 0))
            tok = ""
            depth += {"[": 1, "]": -1}.get(ch, 0)
        else:
            tok += ch
    return params


def expand_leading_optional(params):
    """`[level, ]message` puts an optional parameter first, which LuaLS can't express."""
    lead = [i for i, (_, o) in enumerate(params) if o and any(not o2 for _, o2 in params[i + 1 :])]
    if not lead:
        return [params]
    return [[(p, False) if i in lead else (p, o) for i, (p, o) in enumerate(params)],
            [x for i, x in enumerate(params) if i not in lead]]


def guess_type(name, desc):
    if re.match(r"`(true|false)`", desc) or desc.startswith("Returns whether") or "`true` if" in desc:
        return "boolean"
    return PARAM_TYPES.get(name, "any")


def table_class(name, header, rows):
    lines = ["", f"---@class {name}"]
    has_type = len(header) > 2 and header[1].lower() == "type"
    for row in rows:
        desc = one_line(row[-1])
        for entry in ticks(row[0]):
            m = re.fullmatch(r"\w+([:.])(\w+)(?:\((.*)\))?", entry)
            if m and m.group(1) == ":":
                ps = [f"{p}{'?' if o else ''}: {PARAM_TYPES.get(p, 'any')}" for p, o in parse_params(m.group(3) or "")]
                lines.append(f"---@field {m.group(2)} fun({', '.join([f'self: {name}'] + ps)}): any {desc}")
                continue
            field = m.group(2) if m else entry
            if not re.fullmatch(r"[A-Za-z_]\w*", field):
                continue
            t = row[1] if has_type else guess_type(field, row[-1])
            opt = "" if row[-1].startswith("Required.") else "?"
            lines.append(f"---@field {field}{opt} {t} {desc}".rstrip())
    return lines


def layout_functions(rows, funcs):
    """The rex.layout table lists functions such as `rex.layout.block{ flavor, options }`."""
    for row in rows:
        for entry in ticks(row[0]):
            m = re.fullmatch(r"(rex(?:\.\w+)+)(\(.*\)|\{.*\})", entry)
            if not m:
                continue
            name, args = m.groups()
            if args.startswith("{"):
                fields = [f.strip() for f in args[1:-1].split(",")]
                spec = ", ".join(
                    f"{f}{'' if i == 0 else '?'}: {PARAM_OVERRIDES.get(f'{name}.{f}', PARAM_TYPES.get(f, 'any'))}"
                    for i, f in enumerate(fields)
                )
                PARAM_OVERRIDES.setdefault(f"{name}.spec", f"{{ {spec} }}")
                params = [("spec", False)]
            else:
                params = parse_params(args[1:-1])
            funcs.setdefault(name, {"sigs": [], "doc": comment(row[-1])})["sigs"].append(params)


def gen_lua_ref(md, events_md, overloads):
    secs = sections(md)
    text = "\n".join(line for s in secs for line in s["body"])

    ctx_fields = []
    for m in re.finditer(r"`ctx` has (.+?)\.", text):
        ctx_fields += [f for f in ticks(m.group(1)) if f not in ctx_fields]
    classes = ["", "---@class RexContext"] + [f"---@field {f}? string" for f in ctx_fields]
    classes += ["", "---@alias RexLayout table"]

    funcs = {}  # name -> {"sigs": [[(param, optional)]], "doc": [comment lines]}
    explicit_ns, values = set(), []
    for sec in secs:
        found = tables(sec["body"])
        for header, rows in found:
            if header[0] == "Value":
                values += [(ticks(r[0])[0], one_line(r[-1])) for r in rows if ticks(r[0])]
        generic = re.fullmatch(r"`(rex(?:\.\w+)+)\.<\w+>.*`", sec["title"])
        if generic:
            # `rex.session.<method>(args)`: the methods themselves come from the server API.
            explicit_ns.add(generic.group(1))
            funcs.setdefault(generic.group(1), {"sigs": [], "doc": comment("\n".join(sec["body"]))})
            continue
        sig = re.fullmatch(r"`(rex(?:\.\w+)+)(\(.*\)|\{.*\})?`", sec["title"])
        if not sig:
            continue
        name, args = sig.group(1), sig.group(2) or ""
        if args.startswith("{"):
            params = [("spec", False)]
        else:
            params = parse_params(args[1:-1]) if args else []

        names = TABLE_CLASSES.get(name, [])
        spec_t = opts_t = None
        for i, (header, rows) in enumerate(found):
            cls = names[i] if i < len(names) else None
            if header[0] == "Function":
                layout_functions(rows, funcs)
                continue
            # Method tables without a class name list server methods, which the API covers.
            if header[0] not in ("Field", "Option", "Method") or (header[0] == "Method" and cls is None):
                continue
            cls = cls or ident("Rex", name, header[0], str(i + 1))
            classes += table_class(cls, header, rows)
            if header[0] == "Option":
                opts_t = cls
            elif args.startswith("{") and spec_t is None:
                spec_t = cls
        if spec_t:
            PARAM_OVERRIDES.setdefault(f"{name}.spec", spec_t)
        if opts_t:
            PARAM_OVERRIDES.setdefault(f"{name}.opts", opts_t)
        entry = funcs.setdefault(name, {"sigs": [], "doc": []})
        if args:
            entry["sigs"] += expand_leading_optional(params)
        entry["doc"] += (["---"] if entry["doc"] else []) + comment("\n".join(sec["body"]))

    events, ev_fields = [], []
    for header, rows in tables(events_md.splitlines()):
        for r in rows:
            names = ticks(r[0])
            if not names:
                continue
            if header[0] == "Event":
                events.append((names[0], one_line(r[1])))
            elif header[0] == "Field" and names[0].startswith("ev."):
                ev_fields.append((names[0][3:], one_line(r[-1])))
    classes += ["", "---@alias RexEvent"] + [f"---| {lit(e)} # {w}" for e, w in events] + ["---| string"]
    classes += ["", "---@class RexEventData", "---@field [string] any"]
    classes += [f"---@field {f}? any {d}" for f, d in ev_fields]

    def param_type(name, p):
        return PARAM_OVERRIDES.get(f"{name}.{p}", PARAM_TYPES.get(p, "any"))

    def fun_type(name, params):
        ps = ", ".join(f"{p}{'?' if o else ''}: {param_type(name, p)}" for p, o in params)
        rs = ", ".join(RETURNS.get(name, []))
        return f"fun({ps})" + (f": {rs}" if rs else "")

    namespaces = sorted(explicit_ns | {".".join(n.split(".")[:i]) for n in funcs for i in range(2, len(n.split(".")))})
    out = ["", "---@class Rex", "rex = {}"]
    for ns in namespaces:
        entry = funcs.get(ns, {"sigs": [], "doc": []})
        out += [""] + entry["doc"]
        if entry["sigs"]:
            # A namespace that is also a function, such as rex.exec and rex.exec.start.
            out.append(f"---@class {ident('Rex', ns, 'Module')}")
            out += [f"---@overload {fun_type(ns, s)}" for s in entry["sigs"]]
            out += [f"---@overload {o}" for o in overloads.get(ns, [])]
        out.append(f"{ns} = {{}}")
    for name, entry in funcs.items():
        if name in namespaces:
            continue
        out += [""] + entry["doc"]
        if not entry["sigs"]:
            out.append(f"{name} = {{}}")
            continue
        first = entry["sigs"][0]
        out += [f"---@param {p}{'?' if o else ''} {param_type(name, p)}" for p, o in first]
        out += [f"---@return {r}" for r in RETURNS.get(name, [])]
        out += [f"---@overload {fun_type(name, s)}" for s in entry["sigs"][1:]]
        out += [f"---@overload {o}" for o in overloads.get(name, [])]
        out.append(f"function {name}({', '.join(p for p, _ in first)}) end")
    for name, desc in values:
        out += ["", f"--- {desc}", f"---@type {SCRIPT_VALUE_TYPES.get(name, 'any')}", f"{name} = nil"]
    return classes, out


# --- Main -----------------------------------------------------------------


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--offline", action="store_true", help="use the cached docs instead of downloading them")
    parser.add_argument("--print", action="store_true", help="print the stubs instead of writing files")
    opts = parser.parse_args()

    root = Path(os.environ.get("XDG_DATA_HOME") or Path.home() / ".local/share") / "rex"
    dirs = {d: root / d for d in ("docs", "api", "types")}

    docs = load_docs(dirs["docs"], opts.offline)
    if not docs["lua.md"]:
        log("no copy of lua.md, so only the server API and actions are typed")
    api = rex_json("api", "call", "help.all")
    actions = load_actions()
    version = subprocess.run(["rex", "version"], capture_output=True, text=True).stdout.split("\n")[0]

    S = Schemas()
    api_lines, overloads = gen_api(api, actions, S)
    classes, ref = gen_lua_ref(docs["lua.md"], docs["events.md"], overloads)
    header = ["---@meta rex", f"-- Generated by rex-sync-docs from {version or 'rex'}. Do not edit."]
    stub = "\n".join(header + classes + S.out + ref + api_lines) + "\n"

    if opts.print:
        sys.stdout.write(stub)
        return
    for d in dirs.values():
        d.mkdir(parents=True, exist_ok=True)
    for name, text in docs.items():
        if text:
            (dirs["docs"] / name).write_text(text)
    (dirs["api"] / "api.json").write_text(json.dumps(api, indent=2) + "\n")
    (dirs["api"] / "actions.json").write_text(json.dumps({"actions": actions}, indent=2) + "\n")
    (dirs["types"] / "rex.lua").write_text(stub)
    log(f"wrote {root}")


if __name__ == "__main__":
    main()

# Bifrost

A local [Bifrost](https://docs.getbifrost.ai) AI gateway on `http://localhost:8080`.
It forwards everything to the company gateway at `https://bifrost.r1rcm.com` and
adds logging, a dashboard, caching, per-tool budgets and a shared MCP hub.

```
opencode / claude / codex ──► local gateway (:8080) ──► bifrost.r1rcm.com ──► providers
        ▲                       logs, cache, budgets,
        │                       MCP servers
  bifrost launcher
  (~/.bifrost/bin/bifrost)
```

## Quick start

```bash
bfgw up      # start, or repair whatever is broken (safe to re-run)
bfgw dash    # copy the setup token and open the dashboard
```

`bfgw` is an alias for `bifrost-gateway`. On a fresh machine `setup.sh` runs
`bifrost-gateway setup`, which does the same as `up`. The only manual step is
pasting the r1rcm virtual key when it asks.

## Two programs, both called "bifrost"

This is the main source of confusion.

| | Bifrost **launcher** | Bifrost **gateway** |
|---|---|---|
| What | CLI that starts opencode/claude/codex pointed at a gateway | The HTTP gateway server (`bifrost-http`) |
| Binary | `~/.bifrost/bin/bifrost`, updates itself | `~/Library/Caches/bifrost/<version>/bin/bifrost-http-0` |
| Config | `~/.bifrost/state.json` (contexts) + `~/.bifrost/config.json` | `~/.config/bifrost/config.json`, the stowed `bifrost/config.json` |
| Managed by | `bifrost-gateway cli-sync` | `bifrost-gateway` + launchd |

The npm package `@maximhq/bifrost` also installs a command called `bifrost`
(the gateway). We don't use it; see [Why not npx](#why-not-npx).

## Files

| File | Goes to | Purpose |
|---|---|---|
| `config.json` | `~/.config/bifrost/config.json` (stow) | Gateway config: providers, cache, MCP, budgets |
| `cli.json` | merged into `~/.bifrost/config.json` | Launcher preferences (harness, model, auto install/attach) |
| `bin/bifrost-gateway` | `~/.local/bin/bifrost-gateway` (symlink) | Management script |
| `launchd/ai.getbifrost.gateway.plist` | `~/Library/LaunchAgents/` (rendered copy) | Runs the gateway at login. `__HOME__` is replaced on install |
| `completions/bifrost-gateway.fish` | `~/.config/fish/completions/` (symlink) | Tab completion; `bfgw` inherits it |
| `gateway.version` | read by the script | Pinned gateway release, e.g. `v2.3.2` |
| `.stow-local-ignore` | n/a | Keeps everything except `config.json` out of `~/.config/bifrost` |

Aliases live in `fish/config.fish` and `shell/aliases.sh`.

Runtime state, not in git:

| Path | What |
|---|---|
| `~/.config/bifrost/config.db` | Gateway database (config in use, virtual keys, MCP OAuth tokens) |
| `~/.config/bifrost/logs.db` | Request logs shown in the dashboard |
| `~/.config/bifrost/vectorstore/` | Cache storage (chromem) |
| `~/.config/bifrost/.gateway-started` | Touched on every start; used to detect config changes |
| `~/Library/Logs/bifrost-gateway.{out,err}.log` | Gateway stdout/stderr |

## Commands

```
up                 start or repair everything, copy setup token
down               stop the gateway
dash               copy setup token and open the dashboard
status             running state, health, version
logs [-f]          gateway logs
doctor [--fix]     check everything; --fix repairs what it can
start | stop | restart
secrets [list | --generate | set <name>]
secret <name>      print a keychain secret
upgrade [version]  install a release, pin it, restart
install [version]  download a release without pinning
cli-sync           point the bifrost launcher at this gateway
setup              same as up (used by setup.sh)
```

`run` is what launchd calls. Don't run it by hand: it runs the gateway in the
foreground and fails if the background one already holds port 8080.

### What `up` does

1. Links the script and fish completions.
2. Secrets: asks for `bifrost-r1rcm-vk` if missing, and generates the local ones.
3. Downloads the pinned binary if it isn't cached.
4. `cli-sync`: points the launcher at the local gateway.
5. Installs or refreshes the plist.
6. Starts the gateway, or restarts it if `config.json` or `gateway.version`
   changed since it started, or leaves it alone.
7. Waits for `/health` (about 20s), runs `doctor --quiet`, copies the setup token.

## Secrets

All secrets live in the macOS Keychain (service `bifrost-<name>`, account
`$USER`), never in git. The script exports them as env vars before starting the
gateway, and `config.json` refers to them as `env.VAR`.

| Keychain item | Env var | Source | Used for |
|---|---|---|---|
| `bifrost-r1rcm-vk` | `BIFROST_R1RCM_VK` | **you** (from r1rcm) | Upstream auth to bifrost.r1rcm.com |
| `bifrost-setup-token` | `BIFROST_SETUP_TOKEN` | generated | Unlocks the dashboard until an admin account exists |
| `bifrost-vk-opencode` | `BIFROST_VK_OPENCODE` | generated | Local virtual key; also what the launcher uses |
| `bifrost-vk-claude` | `BIFROST_VK_CLAUDE` | generated | Local virtual key |
| `bifrost-vk-codex` | `BIFROST_VK_CODEX` | generated | Local virtual key |
| `bifrost-vk-scripts` | `BIFROST_VK_SCRIPTS` | generated | Local virtual key for ad-hoc scripts (rate limited) |

```bash
bfgw secrets                  # what exists (never prints values)
bfgw secrets set r1rcm-vk     # paste a new upstream key
bfgw secrets --generate       # create missing local ones
bfgw secret vk-scripts        # print one, e.g. for a script's API key
```

If a required secret is missing at startup, the gateway exits cleanly instead of
crashing, so launchd doesn't restart it over and over. `bfgw up` fixes it.

To add a new secret, add it to `SECRETS` in `bin/bifrost-gateway`, then
reference it as `env.VAR` in `config.json`. `doctor` flags any `env.*` in the
config that isn't in `SECRETS`.

## Gateway config (`config.json`)

- **Providers**
  - `anthropic` points at `https://bifrost.r1rcm.com/anthropic`. It handles
    Claude models directly, so prompt caching and thinking work.
  - `r1rcm` is a custom provider (`base_provider_type: openai`) pointing at
    `https://bifrost.r1rcm.com`. Use it for everything else, e.g.
    `r1rcm/openai/gpt-...`.
  - Both use `BIFROST_R1RCM_VK`. The anthropic route sends it as `x-api-key`;
    `doctor` checks that r1rcm accepts it.
- **Auth**: `enforce_auth_on_inference: true`, so every request needs a local
  virtual key, sent as `Authorization: Bearer` or `x-bf-vk`.
- **Cache**: the `semantic_cache` plugin in direct mode (`dimension: 1`), i.e.
  exact matches only, with a 1h TTL. It skips conversations longer than 3
  messages and responses with tool calls, so agent loops mostly bypass it.
  Similar-prompt matching needs an embedding model from r1rcm.
- **MCP**: linear and sentry (remote, OAuth) and asdste100 (stdio via `uvx`),
  available to every virtual key. Sign in to OAuth servers once from the
  dashboard. With `auto_attach_mcp` the launcher attaches them to each tool.
- **Governance**: monthly budgets of $300 each for opencode and claude, $100 for
  codex and $25 for scripts. Scripts are also limited to 60 requests a minute.

### How edits take effect

The gateway keeps its config in a database (`config.db`). `config.json` is
reconciled into it at startup: an item whose content changed in the file
overwrites the database copy, and items you add in the dashboard are kept. So:

- Edit `config.json`, then run `bfgw up`, which restarts if the file changed.
- Changes made in the dashboard are **not** written back to `config.json`. Copy
  anything you want to keep into the file.

Validate against the schema before restarting:

```bash
uvx check-jsonschema --schemafile https://www.getbifrost.ai/schema bifrost/config.json
```

## Launcher integration

The launcher regenerates `~/.bifrost/config.json` from its current **context**
(stored in `state.json`) and keeps virtual keys in the Keychain. Symlinking or
hand-editing `base_url` / `virtual_key` in that file does not stick.
`cli-sync` uses the launcher's own CLI instead:

```bash
bifrost context add local --base-url http://localhost:8080 --default-model anthropic/claude-opus-5-5
bifrost context use local
bifrost --context local auth set-virtual-key --stdin   # bifrost-vk-opencode
```

It then merges `cli.json` into `~/.bifrost/config.json` for the remaining
preferences. The `base_url` that file still shows is left over from the old
format; the current context is what's used.

- `bifrost context list` shows `local` (current) and `default` (r1rcm).
- **Gateway down?** `bifrost --context default` goes straight to r1rcm.
- Every tool launched through the launcher uses `vk-opencode`. For separate
  per-tool budgets, give that tool its own key (e.g. `bfgw secret vk-claude`).

## Dashboard

`bfgw dash`, then paste the token (it's already on the clipboard).

Until an admin account exists, Bifrost rejects every dashboard request that
doesn't carry the setup token ("No setup token is configured on this
server..."). For a username and password instead, create an admin under
**Workspace → Config → Security**. After that the token is no longer used.

## Upgrades

```bash
bfgw upgrade           # latest release
bfgw upgrade v2.3.2    # specific release
```

This downloads the binary, writes `gateway.version` and restarts the gateway.
Commit `gateway.version`; to roll back, revert it and run `bfgw up`. `doctor`
warns when a newer release exists. Nothing upgrades automatically.

The launcher updates itself independently. Its v1.0.0 update introduced
contexts and broke the old config-file approach.

## Why not npx

The documented `npx -y @maximhq/bifrost` is a Node wrapper that contacts
getbifrost.ai on every start, downloads the binary, and runs it as a child
process. Under launchd:

- launchd stops Node, and the child can keep port 8080, so the next start fails;
- with no network at login it downloads into a temp dir, fails, and launchd
  keeps retrying in a loop.

The script downloads from the same URL
(`downloads.getmaxim.ai/bifrost/<ver>/darwin/<arch>/bifrost-http`) into the same
cache path npx uses, then runs the binary directly with `exec`.

## Troubleshooting

Start with `bfgw doctor` (or `bfgw doctor --fix`).

| Symptom | Cause / fix |
|---|---|
| Dashboard: "No setup token is configured" | `bfgw up` (creates the token), then `bfgw dash` and paste it |
| Dashboard requests return 401 | Token not pasted, or wrong; `bfgw dash` copies it again |
| Launcher goes to r1rcm instead of local | Launcher context changed or it updated itself: `bfgw cli-sync` |
| `bfgw status`: loaded but not healthy | `bfgw logs`; often port 8080 busy (`lsof -iTCP:8080`) or a bad config |
| Gateway exits right after start, no error | A required secret is missing: `bfgw secrets` |
| Config edit has no effect | `bfgw up`; if the dashboard changed the same item, the database copy may win until the file content changes |
| MCP tools show up twice in opencode | Remove the `mcp` block from `opencode/opencode.jsonc`; the gateway serves them |
| Anthropic route rejected upstream | Add `network_config.extra_headers` with `x-bf-vk` to the `anthropic` provider |

To reset local state, run `bfgw down`, then delete `config.db`, `logs.db` and
`vectorstore/` in `~/.config/bifrost` (keep `config.json`), then `bfgw up`.
This throws away logs and MCP OAuth sign-ins.

To remove everything:

```bash
bfgw down
rm ~/Library/LaunchAgents/ai.getbifrost.gateway.plist ~/.local/bin/bifrost-gateway \
   ~/.config/fish/completions/bifrost-gateway.fish
bifrost context use default
```

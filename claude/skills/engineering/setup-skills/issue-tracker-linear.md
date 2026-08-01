# Issue tracker: Linear

Issues and PRDs for this repo live as Linear issues. Use the Linear MCP tools for all operations.

**Team:** `<team name or key — set once when this repo is configured>`. Linear has no `git remote`-equivalent to infer this from; it must be recorded explicitly (see setup-skills Section A). If this repo's work spans multiple Linear teams, list them all here and note how to pick between them.

## Conventions

- **Create an issue**: `save_issue(team: <team>, title: "...", description: "...")`.
- **Read an issue**: `get_issue(id)` — pass `includeRelations: true` when blocking/related/duplicate links matter.
- **List issues**: `list_issues(team: <team>, state: "...", assignee: "...", query: "...")`.
- **Comment on an issue**: `save_comment(issueId: <id>, body: "...")`.
- **Close**: resolve the team's terminal workflow state name first — `list_issue_statuses(team: <team>)` (usually `Done` or `Canceled`) — then `save_issue(id, state: "<name>")`.

Refer to issues by their identifier (e.g. `ENG-123`) or UUID — both work everywhere an `id` param is expected.

## Pull requests as a triage surface

Omitted. Linear doesn't host this repo's pull requests — code and PRs live on whichever git host this repo actually uses. If that host also needs a triage surface, see its own tracker doc (e.g. `issue-tracker-github.md`) rather than this one.

## When a skill says "publish to the issue tracker"

Create a Linear issue: `save_issue(team: <team>, title: "...", description: "...")`.

## When a skill says "fetch the relevant ticket"

`get_issue(id)`.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue, holding the Notes / Decisions-so-far / Fog body. `save_issue(team: <team>, title: "...", description: "...")`.
- **Child ticket**: `save_issue(team: <team>, parentId: <map id>, title: "...", description: "...")` — Linear's `parentId` is native, so no task-list fallback is needed. Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: Linear's **native** `blockedBy`/`blocks` params on `save_issue` — append-only, existing relations are never removed. `save_issue(id: <child>, blockedBy: [<blocker id>])`. Read back with `get_issue(id, includeRelations: true)`. A ticket is unblocked when every blocker is closed.
- **Frontier query**: `list_issues(parentId: <map id>, fields: ["statusType", "assigneeId"], orderBy: "createdAt")`, drop anything with `statusType` in `completed`/`canceled`, drop anything with `assigneeId` set, then `get_issue(includeRelations: true)` on the remainder and drop any with an open issue in `blockedBy`. First by creation order wins.
- **Claim**: `save_issue(id, assignee: "me")` — the session's first write.
- **Resolve**: `save_comment(issueId: <id>, body: "<answer>")`, then `save_issue(id, state: "<Done state>")`, then append a context pointer to the map's Decisions-so-far via `save_issue(id: <map id>, patch: [{ op: "insert_after", anchor: "## Decisions so far", text: "\n- [<title>](link) — <gist>" }])`.

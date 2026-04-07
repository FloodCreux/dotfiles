---
name: transition_update
description: Updates a TRANSITION.md document in the repo with the latest changes from git history. Use this skill whenever the user asks to update a transition doc, sync a transition file, or says things like "update the transition doc", "update TRANSITION.md", or "what's changed since the last transition update". Trigger this even if they just say "transition" in a git repo context.
---

## Purpose

You maintain a project's `TRANSITION.md` document — a living record that tracks how a codebase is evolving. Transition docs vary by project: some track migration progress, others document architectural shifts, API changes, deprecations, or team handoff status. Your job is to read the existing document, understand its purpose and structure, then update it with accurate information drawn from the git history.

## Steps

### 1. Find the transition document

Search for `TRANSITION.md` (case-insensitive) in the repo root and common locations:

- `./TRANSITION.md`
- `./docs/TRANSITION.md`
- `./doc/TRANSITION.md`

Use `find . -maxdepth 3 -iname "TRANSITION.md"` if the file isn't in an obvious location.

If no transition document exists, stop and ask the user whether they want to create one. Do not create it automatically.

### 2. Read and understand the existing document

Read the full `TRANSITION.md` before making any changes. Determine:

- **What the document tracks** — Is it a migration plan? An architecture change log? A handoff document? A deprecation tracker? Something else entirely?
- **What structure it uses** — Sections, headings, date formats, status markers, checklists, tables, or freeform prose.
- **What voice and conventions it follows** — Terse bullet points vs. narrative paragraphs, first-person vs. third-person, how entries are ordered (chronological, reverse-chronological, by component).
- **Where the document left off** — What was the last update? What date or commit does it cover up to? What items are marked as in-progress or pending?

This understanding is critical. You must preserve the document's existing purpose, tone, and structure. Do not impose a new format.

### 3. Gather git history since last update

Determine the boundary for new changes. Look for:

- A date in the last entry of the document
- A commit hash or tag referenced in the document
- A version number that can be mapped to a tag

Then gather the relevant history:

```bash
# If you found a date boundary:
git log --since="<date>" --oneline --no-merges
git log --since="<date>" --oneline --merges

# If you found a commit boundary:
git log <commit>..HEAD --oneline --no-merges
git log <commit>..HEAD --oneline --merges

# If no clear boundary, get recent history and ask the user:
git log --oneline -50
```

Also run these to understand the shape of changes:

- `git log --since="<boundary>" --stat` — which files changed and how much
- `git log --since="<boundary>" --format="%h %s" --no-merges` — concise commit subjects
- `git branch -a --sort=-committerdate | head -20` — recent branch activity
- `git tag --sort=-creatordate | head -10` — recent tags/releases

If the diff is large, read key commits or merges in detail with `git show <hash>` to understand significant changes.

### 4. Analyze and categorize changes

Group the changes into categories that match what the transition document already tracks. Common patterns include:

- **Completed work** — items previously marked in-progress that are now done
- **New developments** — significant changes not previously mentioned
- **Status changes** — things that moved forward, stalled, or changed direction
- **New risks or blockers** — problems that emerged
- **Deprecations** — things being phased out
- **Migration progress** — what has been migrated, what remains

Do not invent categories the document doesn't use. Fit new information into the existing structure.

### 5. Update the document

Apply changes while following these rules:

- **Preserve the existing structure exactly.** Match heading levels, list styles, date formats, and section ordering.
- **Update in-progress items** whose status changed based on the git history. Move completed items to the appropriate section if the document uses that pattern.
- **Add new entries** in the style and location consistent with existing entries. If the document is reverse-chronological, add at the top. If chronological, add at the bottom.
- **Include a date or reference point** so the next update knows where this one left off. Use whatever convention the document already uses (dates, commit hashes, version numbers).
- **Do not remove or rewrite existing content** unless it is factually incorrect based on what the git history shows. Transition docs are historical records — edits should be additive.
- **Do not editorialize.** State what changed factually. Avoid subjective assessments like "great progress" or "unfortunately delayed" unless the existing document uses that voice.
- **Keep the same level of detail.** If existing entries are terse one-liners, don't write paragraphs. If they're detailed narratives, don't reduce to bullets.

### 6. Summarize what you changed

After editing, tell the user:

- How many new entries or updates you added
- What date/commit range the update covers
- Any items you weren't sure about — for example, in-progress items where the git history was ambiguous about whether they're complete
- Any items that may need the user's input (status judgments, context you don't have from code alone)

## Edge cases

- **Multiple TRANSITION.md files**: If the repo has more than one, list them and ask the user which to update.
- **No clear boundary**: If you can't determine where the last update ended, show the user the last few entries and recent git history, then ask them to confirm the boundary before proceeding.
- **Massive history**: If there are hundreds of commits since the last update, focus on merge commits, tagged releases, and changes to key files rather than listing every commit. Summarize thematically.
- **Conflicting information**: If the git history contradicts something in the transition doc (e.g., a "completed" item was reverted), flag it to the user rather than silently correcting it.

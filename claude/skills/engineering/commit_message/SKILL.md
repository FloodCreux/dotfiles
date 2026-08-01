---
name: commit_message
description: Generates git commit messages from staged changes. Use this skill whenever the user asks to commit, write a commit message, or says things like "commit this", "commit my changes", or "what should the commit message be" — even if they don't explicitly mention "commit message".
---

## How it works

1. **Read the staged diff** with `git diff --cached` to understand what's actually changing.
2. **Read recent commit history** with `git log --oneline -10` to match the project's existing style and voice.
3. **Write a commit message** based on the diff content.

## Commit message format

Use Conventional Commits:

```
<type>(<scope>): <short description>
```

Where `<type>` is one of: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `style`, `ci`, `perf`, `build`.

The `<scope>` is optional — include it when the change is clearly scoped to a specific module, component, or area of the codebase. Omit it for broad or cross-cutting changes.

Keep the first line under 72 characters.

## When to use a multi-line message

If the staged diff is more than >=100 lines, add a body after a blank line:

```
<type>(<scope>): <short description>

- Bullet points explaining the key changes
- Focus on *why* things changed, not just *what* changed
- Keep each bullet concise
```

For smaller diffs (under ~100 lines), a single line is enough — don't pad it with unnecessary detail.

## Choosing the type

Pick the type that best describes the _intent_ of the change, not just what files were touched:

- `feat` — new functionality visible to users
- `fix` — corrects a bug or broken behavior
- `refactor` — restructures code without changing behavior
- `docs` — documentation only
- `chore` — maintenance, dependencies, config
- `test` — adding or updating tests
- `style` — formatting, whitespace, linting (no logic changes)
- `ci` — CI/CD pipeline changes
- `perf` — performance improvements
- `build` — build system or tooling changes

## Writing good descriptions

The short description should say what the change _does_, in imperative mood ("add", "fix", "update" — not "added", "fixes", "updates"). Be specific: "fix login redirect loop" is better than "fix bug". Avoid vague messages like "update code" or "various changes".

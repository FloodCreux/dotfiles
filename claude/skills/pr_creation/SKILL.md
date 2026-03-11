---
name: pr_creation
description: Generates PR titles and descriptions. Use this skill whenever the user asks to create a PR, write a PR description, draft a pull request, or prepare changes for review — even if they just say something like "PR this" or "open a pull request".
---

## How it works

Before writing anything, gather context about what changed:

1. **Check for a repo PR template** at `.github/PULL_REQUEST_TEMPLATE.md`. If one exists, use its structure instead of the default template below.
2. **Read the git diff and log** to understand the actual changes:
   - `git diff main...HEAD` (or the appropriate base branch) for the full diff
   - `git log main...HEAD --oneline` for the commit history
3. **Generate the title and description** based on what the code actually does, not generic placeholders.

## Title format

```
<type>: <short description>
```

Where `<type>` is one of: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `style`, `ci`, `perf`.

Keep the title under 72 characters. The short description should summarize the change in plain language — what it does, not how.

## Default description template

Use this structure when the repo has no PR template:

```markdown
## Description

<!-- Summarize what this PR does and why, based on the diff. Be specific. -->

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Tests pass locally
- [ ] Added/updated tests for changes

## Checklist

- [ ] Code follows project style guidelines
- [ ] Updated documentation
- [ ] Updated changelog files
```

Fill in the Description section with a real summary derived from the diff — don't leave the HTML comment placeholder. Check the appropriate boxes in Type of Change based on what the diff shows.

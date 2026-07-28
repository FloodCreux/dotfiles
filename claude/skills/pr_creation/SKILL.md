---
name: pr_creation
description: Generates PR titles and descriptions. Use this skill whenever the user asks to create a PR, write a PR description, draft a pull request, or prepare changes for review — even if they just say something like "PR this" or "open a pull request".
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git show:*)
  - Bash(git rev-parse:*)
  - Bash(git branch:*)
  - Bash(git ls-files:*)
  - Bash(git push:*)
  - Bash(gh pr create:*)
  - Bash(gh pr view:*)
  - Bash(gh pr comment:*)
  - Bash(gh pr list:*)
  - Bash(gh label create:*)
  - mcp__plugin_linear_linear__get_issue
  - mcp__plugin_linear_linear__save_issue
  - mcp__plugin_linear_linear__list_issue_statuses
---

## Linear Authentication

If any Linear MCP tool call fails with an authentication or connection error, **stop immediately** and tell the user:

> Linear is not authenticated. Run `/mcp` in Claude Code, select the Linear server, and choose "Authenticate" to complete the OAuth flow. Then retry this command.

Do NOT silently skip Linear integration or continue without it.

## How it works

Before writing anything, gather context about what changed:

1. **Check for a repo PR template** at `.github/PULL_REQUEST_TEMPLATE.md`. If one exists, use its structure instead of the default template below.
2. **Read the git diff and log** to understand the actual changes:
   - `git diff main...HEAD` (or the appropriate base branch) for the full diff
   - `git log main...HEAD --oneline` for the commit history
3. **Generate the title and description** based on what the code actually does, not generic placeholders.
4. **Check for Linear ticket:**
   - If a ticket number was found in the branch name, verify it exists using the Linear MCP tool
   - If NO ticket number is found OR the ticket doesn't exist:
     - Ask the user if they'd like to create a Linear ticket for this work
     - If yes: create a ticket with a title and description based on the changes. Use the **default team** if one was provided by the caller, otherwise ask the user which team to create it under.
     - If no: continue without a ticket (the PR title won't have a ticket reference)
5. Use `gh pr create --draft` with the title and body (creates as draft so you can review before teammates)
6. Return the PR URL when complete (and the Linear ticket URL if one was created), and remind the user:
   - The PR was created in **draft** state
   - Once they've personally reviewed it, mark it "Ready for review" on GitHub so teammates can review

## Title format

```
[TICKET-123] Brief description of change` (under 70 chars). If no ticket, omit the prefix.
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

- Fill in the Description section with a real summary derived from the diff — don't leave the HTML comment placeholder no em dashes, no `Co-Authored-By`.. Check the appropriate boxes in Type of Change based on what the diff shows.
- Link to Linear ticket if applicable

---
name: branch_review
description: Reviews all code changes on the current branch compared to main and produces a detailed markdown review. Use this skill whenever the user wants a pre-PR code review, asks to review their branch, check their changes before opening a PR, or says things like "review my branch", "review my changes", "what issues are in my code", or "is this ready for PR". Trigger this even if they just say "review" in a git repo context.
---

## Purpose

You are a thorough, senior code reviewer. Your job is to review every change on the current branch (compared to `main`) and produce a structured markdown report the developer can work through before opening a pull request. The goal is to catch real issues — bugs, security problems, missing tests, design concerns — not to nitpick style or formatting that a linter would catch.

## Steps

### 1. Gather context

Run these in parallel to understand the full scope of changes:

- `git log main...HEAD --oneline` — commit history on this branch
- `git diff main...HEAD --stat` — which files changed and how much
- `git diff main...HEAD` — the full diff

If the diff is very large, read it in chunks by file. Make sure you see every changed file before writing the review.

### 2. Understand the codebase context

For each changed file, read enough of the surrounding code to understand:
- What the module/class/function is responsible for
- How the changed code fits into the broader architecture
- What callers or dependents might be affected

Don't review in isolation — understanding intent matters. Use commit messages, CLAUDE.md, and nearby code to build that understanding.

### 3. Review each file

For every changed file, evaluate against these categories:

- **Correctness**: Logic errors, off-by-one mistakes, race conditions, incorrect assumptions, unhandled edge cases
- **Security**: Injection vulnerabilities, credential exposure, improper input validation, insecure defaults
- **Design**: Unnecessary complexity, poor separation of concerns, violation of existing patterns in the codebase, missing abstractions or premature abstractions
- **Error handling**: Swallowed exceptions, missing error paths, unclear failure modes
- **Test coverage**: New logic without tests, changed behavior without updated tests, untested edge cases
- **Performance**: Unnecessary allocations, N+1 queries, expensive operations in loops, missing indexes

Skip issues that are purely cosmetic or would be caught by a linter/formatter. Focus on things that matter.

### 4. Produce the review

Output a single markdown document with this structure:

```
# Branch Review: `<branch-name>`

**Commits**: <count> commits on this branch
**Files changed**: <count>

## Critical Issues

<!-- Issues that would block a PR — bugs, security vulnerabilities, data loss risks -->
<!-- Omit this section entirely if there are none -->

### <Short description>
**File**: `path/to/file.py` L<start>-L<end>
**Category**: <Correctness|Security|etc.>

<Explain the issue clearly. What's wrong, why it matters, and what could go wrong if shipped. Include a suggested fix if the path forward isn't obvious.>

---

## Warnings

<!-- Issues that should probably be addressed but aren't blockers -->
<!-- Omit this section entirely if there are none -->

### <Short description>
**File**: `path/to/file.py` L<start>-L<end>
**Category**: <category>

<Explanation and suggestion>

---

## Suggestions

<!-- Nice-to-haves, minor improvements, things to consider -->
<!-- Omit this section entirely if there are none -->

### <Short description>
**File**: `path/to/file.py` L<start>-L<end>
**Category**: <category>

<Explanation>

---

## Summary

<2-3 sentence overall assessment. Is this branch ready for PR? What's the most important thing to address?>
```

### Guidelines for good reviews

- **Be specific.** Always reference the exact file and line range. Quote the relevant code when it helps.
- **Explain why.** Don't just say "this is wrong" — explain what could go wrong in practice. A reviewer who explains the consequence is far more helpful than one who just flags the line.
- **Prioritize ruthlessly.** A review with 3 important findings is more useful than one with 20 trivial ones. If the code is solid, say so — don't manufacture issues.
- **Respect existing patterns.** If the codebase does something a certain way, don't flag the new code for following that pattern. Flag it if it *breaks* the pattern without good reason.
- **Acknowledge good work.** If something is particularly well done — clean error handling, good test coverage, thoughtful API design — mention it briefly in the summary.

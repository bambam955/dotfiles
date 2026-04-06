---
name: implement-gitlab-issue
description: "Implement a GitLab issue end to end. Use when Codex is asked to take a GitLab issue, issue URL, or issue number, read the issue and comments, gather repository context, make the code change, run validation, review the diff, and create a merge request."
---

# Implement GitLab Issue

Turn a GitLab issue into a reviewed merge request. Start from the issue, build only the context needed to implement it, validate the change, review your own diff critically, and open the MR only when the branch is in a defensible state.

## Invocation

- Treat a bare number after the skill name as the GitLab issue number in the current repository.
- Example: `$implement-gitlab-issue 56` means to implement issue `56`.

## Workflow

### 1. Read the issue

- Fetch the issue title, description, comments, labels, and linked references with `glab issue view`.
- Extract acceptance criteria, constraints, rollout notes, and ambiguity that could change implementation.
- If the issue is thin, inspect linked code, merge requests, or nearby docs before asking the user.

### 2. Build context

- Check the working tree first with `git status --short`; do not overwrite unrelated local changes.
- Use `rg` to find the relevant code paths, tests, feature flags, config, and recent history.
- Read the smallest set of files that explains the current behavior and the expected change.
- Ask the user only when a product decision or acceptance criterion cannot be inferred from the issue or code.

### 3. Prepare the branch

- Stay on the current branch if it is already the intended feature branch.
- Otherwise create a branch named `<issue-id>-<kebab-case-issue-title>`, matching GitLab's default issue branch convention.
- Keep the branch scoped to the issue. Avoid opportunistic cleanup unless it is required for the fix.

### 4. Implement

- Make the code changes directly unless the user explicitly asked for design or planning first.
- Match the repository's conventions for architecture, naming, formatting, tests, and commit messages.
- Add or update tests when behavior changes. If test coverage is not practical, record why.
- Work carefully in dirty trees and preserve existing user changes.

### 5. Validate

- Run the narrowest useful checks first, then broaden only as needed.
- Prefer repository-native test, lint, and build commands.
- Fix failures, flaky assumptions, and generated diffs before moving on.
- If a required validation step cannot run, capture the exact reason and resulting risk.

### 6. Review your own diff

- Read the diff as a reviewer, not the author.
- Check for correctness, regressions, missing tests, edge cases, naming problems, and accidental scope growth.
- Tighten the code, tests, or docs before opening the MR.
- Confirm `git status` is clean except for intentional changes.

### 7. Commit, push, and open the MR

- Create logical commits with Conventional Commit messages.
- Push the branch and create the merge request with `glab mr create`.
- Write an MR title and description that reference the issue and always include:
  `## Summary`
  `## Testing`
  - The testing steps should be in checklist form so that reviewers can make clear to an author what worked and didn't work for them.
- Create a draft MR instead of a ready MR when validation is incomplete or open questions remain.

## Operating Rules

- Prefer `glab` for issue and merge request operations.
- Prefer `rg` for repository search and gather only the context needed for the task.
- Always use Conventional Commit messages for commits created during this workflow.
- Never overwrite unrelated local changes or revert work you did not make.
- Never open a ready MR with known failing validation unless the user explicitly wants a draft for early feedback.
- Surface blockers early when credentials, permissions, CI failures, or missing product decisions prevent completion.

## Merge Request Checklist

- The implementation matches the issue's acceptance criteria.
- The diff is scoped, readable, and limited to intentional changes.
- Validation covers the changed behavior well enough for the repository.
- The branch name follows `<issue-id>-<kebab-case-issue-title>`.
- Every commit uses Conventional Commits.
- The branch is pushed and the MR description includes `## Summary` and `## Testing`.

# Global AGENTS.md

## Dev Workflow

- Always look for `just` recipes that may be useful during development. Many projects have them, and commands in the `justfile`s make it clear what the typical dev cycle looks like.

## Documentation

- Be verbose with comments on all source code even if it seems simple.
  - Good documentation is very crucial to the success of any project. It's important for others to be able to see exactly why you chose a particular implementation.

## Git

- ALWAYS use Conventional Commit messages for all Git commits
- NEVER use `git commit --amend`. Always make new commits.
- ASK before using `git commit --no-verify`. Let pre-commit hooks run. If they fail, fix the underlying issues instead of bypassing.

## Testing

- Do not get sidetracked wasting time trying to test something. Many times, the cost doing so is not worth it.
  - You should never be spending more time writing tests/trying to test than implementing the code itself.

## Working with MRs/PRs

- When writing testing steps in MRs/PRs:
  - Always use checklists. This allows reviewers to make it clear to the author what works and what doesn't.
  - NEVER reference host-local files that aren't part of the repo. This is extremely unhelpful to reviewers because they don't have access to this PC.
- Use the `glab` and `gh` CLIs confidently. They are both installed and authenticated.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->

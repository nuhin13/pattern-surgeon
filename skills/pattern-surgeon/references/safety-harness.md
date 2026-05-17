# Safety Harness Protocol

Never keep an edit without a green verify.

1. Run `scripts/checkpoint.sh` — capture SHA. Abort the whole operation if it
   exits non-zero (not a git repo).
2. Apply the refactor edits.
3. Run `scripts/verify.sh`.
   - Exit 0 → keep changes. Summarize what changed and why.
   - Exit 2 (typecheck) / 3 (tests) → run `scripts/rollback.sh <SHA>`, show the
     rejected diff and the first failure, offer EXACTLY ONE retry.
   - Exit 4 (no test script) → see legacy handling in SKILL.md; do NOT keep
     unverified edits.
4. One auto-retry maximum. After a second failure, stop and report. Never loop.

## Limitation
`checkpoint.sh` snapshots tracked files only (`git stash create` ignores
untracked files). If the scope file is not yet git-tracked, the refactor
cannot be safely auto-reverted: ask the user to `git add` it first (a bare
`git add -N` is enough), or fall back to recommend-only.

#!/usr/bin/env bash
set -euo pipefail
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "pattern-surgeon: not a git repo; cannot checkpoint" >&2; exit 1; }
sha="$(git stash create "pattern-surgeon checkpoint" || true)"
[ -n "$sha" ] || sha="$(git rev-parse HEAD)"   # clean tree: pin HEAD
echo "$sha"

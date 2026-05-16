setup() {
  TMP="$(mktemp -d)"; cd "$TMP"
  export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
  git init -q
  echo a > f.txt; git add .; git commit -qm init
  echo b > f.txt   # dirty working tree
}
teardown() { rm -rf "$TMP"; }

@test "checkpoint prints a stash sha and leaves working tree unchanged" {
  run bash "$BATS_TEST_DIRNAME/../../skills/pattern-surgeon/scripts/checkpoint.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9a-f]{40}$ ]]
  [ "$(cat f.txt)" = "b" ]
}

@test "checkpoint aborts when not a git repo" {
  cd "$TMP"; rm -rf .git
  run bash "$BATS_TEST_DIRNAME/../../skills/pattern-surgeon/scripts/checkpoint.sh"
  [ "$status" -ne 0 ]
}

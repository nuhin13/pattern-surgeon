setup() {
  TMP="$(mktemp -d)"; cd "$TMP"
  git init -q; git config user.email t@t; git config user.name t
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

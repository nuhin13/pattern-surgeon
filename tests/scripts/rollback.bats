SCRIPT="$BATS_TEST_DIRNAME/../../skills/pattern-surgeon/scripts/rollback.sh"
CP="$BATS_TEST_DIRNAME/../../skills/pattern-surgeon/scripts/checkpoint.sh"
setup() {
  TMP="$(mktemp -d)"; cd "$TMP"
  git init -q; git config user.email t@t; git config user.name t
  echo good > f.txt; git add .; git commit -qm init
  echo bad > f.txt
  SHA="$(bash "$CP")"
}
teardown() { rm -rf "$TMP"; }

@test "rollback restores checkpoint contents and prints rejected diff" {
  echo worse > f.txt
  run bash "$SCRIPT" "$SHA"
  [ "$status" -eq 0 ]
  [ "$(cat f.txt)" = "bad" ]
  [[ "$output" == *"REJECTED DIFF"* ]]
}

ROOT="$BATS_TEST_DIRNAME/../../skills/pattern-surgeon/references/patterns"
SKILL="$BATS_TEST_DIRNAME/../../skills/pattern-surgeon/SKILL.md"
FIX="$BATS_TEST_DIRNAME/../fixtures"

# ── File existence after GoF rename ─────────────────────────────────────────

@test "factory-method.md exists (GoF rename)" {
  [ -f "$ROOT/factory-method.md" ]
}

@test "factory.md no longer exists after GoF rename" {
  [ ! -f "$ROOT/factory.md" ]
}

# ── GoF participants present in all four GoF pattern refs ────────────────────

@test "strategy.md has GoF participants section" {
  grep -qF "## GoF participants" "$ROOT/strategy.md"
}

@test "factory-method.md has GoF participants section" {
  grep -qF "## GoF participants" "$ROOT/factory-method.md"
}

@test "adapter.md has GoF participants section" {
  grep -qF "## GoF participants" "$ROOT/adapter.md"
}

@test "observer.md has GoF participants section" {
  grep -qF "## GoF participants" "$ROOT/observer.md"
}

# ── Strategy: Context + runtime swap ─────────────────────────────────────────

@test "strategy.md documents the Context participant" {
  grep -qiF "Context" "$ROOT/strategy.md"
}

@test "strategy.md documents ConcreteStrategy participant" {
  grep -qF "ConcreteStrategy" "$ROOT/strategy.md"
}

@test "strategy.md documents runtime swap via setStrategy" {
  grep -qiF "runtime" "$ROOT/strategy.md"
  grep -qF "setStrategy" "$ROOT/strategy.md"
}

# ── Factory Method: Creator / ConcreteCreator / Product ──────────────────────

@test "factory-method.md documents Creator participant" {
  grep -qF "Creator" "$ROOT/factory-method.md"
}

@test "factory-method.md documents ConcreteCreator participant" {
  grep -qF "ConcreteCreator" "$ROOT/factory-method.md"
}

@test "factory-method.md documents Product and ConcreteProduct participants" {
  grep -qF "Product" "$ROOT/factory-method.md"
  grep -qF "ConcreteProduct" "$ROOT/factory-method.md"
}

@test "factory-method.md shows GoF canonical Creator subclassing form" {
  grep -qF "abstract class ConnCreator" "$ROOT/factory-method.md"
  grep -qF "createConn" "$ROOT/factory-method.md"
}

# ── Adapter: Target / Adaptee / Object vs Class Adapter ──────────────────────

@test "adapter.md documents Target participant" {
  grep -qF "Target" "$ROOT/adapter.md"
}

@test "adapter.md documents Adaptee participant" {
  grep -qF "Adaptee" "$ROOT/adapter.md"
}

@test "adapter.md notes Object Adapter variant" {
  grep -qiF "Object Adapter" "$ROOT/adapter.md"
}

@test "adapter.md notes Class Adapter variant" {
  grep -qiF "Class Adapter" "$ROOT/adapter.md"
}

# ── Observer: Subject / ConcreteSubject / Observer / pull model ───────────────

@test "observer.md documents Subject participant" {
  grep -qF "Subject" "$ROOT/observer.md"
}

@test "observer.md documents ConcreteSubject participant" {
  grep -qF "ConcreteSubject" "$ROOT/observer.md"
}

@test "observer.md documents ConcreteObserver participant" {
  grep -qF "ConcreteObserver" "$ROOT/observer.md"
}

@test "observer.md documents Observer interface with update method" {
  grep -qF "Observer" "$ROOT/observer.md"
  grep -qiF "update" "$ROOT/observer.md"
}

@test "observer.md mentions GoF pull model" {
  grep -qiF "pull model" "$ROOT/observer.md"
}

# ── SKILL.md detection rules: Factory → Factory Method ───────────────────────

@test "SKILL.md detection rules list Factory Method" {
  grep -qF "Factory Method" "$SKILL"
}

@test "SKILL.md detection rules no longer have bare Factory row" {
  ! grep -qE '^\| Factory \|' "$SKILL"
}

@test "SKILL.md Lazy Loading Protocol mentions sibling files" {
  grep -qF "sibling files" "$SKILL"
}

# ── factory-method-gof-pos fixture ───────────────────────────────────────────

@test "factory-method-gof-pos fixture src.ts exists" {
  [ -f "$FIX/factory-method-gof-pos/src.ts" ]
}

@test "factory-method-gof-pos fixture demonstrates Creator subclass structure" {
  f="$FIX/factory-method-gof-pos/src.ts"
  [ -f "$f" ]
  grep -qiF "Creator" "$f"
  grep -qF "abstract" "$f"
  grep -qF "createConn" "$f"
}

@test "factory-method-gof-pos fixture tests pass" {
  d="$FIX/factory-method-gof-pos"
  command -v node >/dev/null 2>&1 || skip "node not installed"
  [ -f "$d/test.js" ]
  run node "$d/test.js"
  [ "$status" -eq 0 ]
}

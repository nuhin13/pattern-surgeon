# pattern-surgeon Modes Extension — Design Spec

**Date:** 2026-05-18
**Status:** Approved (design); pending implementation plan
**Base branch:** `feat/pattern-surgeon-multilang`
**Extends:** `docs/superpowers/specs/2026-05-17-pattern-surgeon-design.md`,
`docs/superpowers/specs/2026-05-17-pattern-surgeon-multilang-design.md`

## Problem

`pattern-surgeon` today does two things: **suggest** a pattern for a named
TS/JS/Python/Java/C#/PHP scope and **refactor** that scope to it under a
verify-or-revert safety net. Users also want to: (1) **compare** candidate
patterns for a position and understand which/why/how it fits, (2) make new
code **follow existing patterns** already present in the codebase, and (3)
**implement** new behavior with the right pattern from scratch (greenfield),
not only refactor existing code. This extension delivers all three as a single
evolved skill without rewriting the working substrate or weakening the safety
contract.

## Goals

- One skill (`pattern-surgeon`), evolved — not a new or replacement skill.
- Add three modes: `compare`, `follow`, `greenfield`.
- Preserve the verify-or-revert safety contract (exit `0/2/3/4`) for every
  mode that mutates code, across all supported languages.
- Greenfield work keeps the safety guarantee via TDD-first (a failing test
  must exist before implementation).
- `follow` honors the existing reactive-only rule (no unprompted repo scan).
- Existing TS + multi-language tests and fixtures stay 100% green
  (additive change only).

## Non-Goals

- No new design pattern beyond the existing 6 (Strategy, Factory, Adapter,
  Repository, Observer, Dependency-Injection).
- No new pattern of separate skills (decided: extend, not split).
- No repo-wide pattern census or build orchestration.
- No new safety scripts; reuse `verify.sh` / `checkpoint.sh` / `rollback.sh`.

## Architecture

Single SKILL.md, mode-router front. An **Intent routing** step precedes the
existing Procedure and maps the user request to exactly one mode.

| Mode | Trigger | Status | Mutates code? |
|---|---|---|---|
| `suggest` | "what pattern fits X" | exists | no |
| `refactor` | "refactor X to a pattern" / messy code | exists | yes |
| `compare` | "which: A or B", "compare patterns for X", "why this over that" | new | no |
| `follow` | "match existing patterns here", "make this consistent" | new | optional |
| `greenfield` | "implement X with the right pattern" (X not yet coded) | new | yes |

Shared substrate, unchanged, reused by all modes:

- Language + framework detection step.
- `references/patterns/*.md` (6 files, per-language blocks + `## Framework idiom`).
- `references/safety-harness.md` + `scripts/verify.sh|checkpoint.sh|rollback.sh`.

New files: `references/comparison-rubric.md`, `references/greenfield-tdd.md`.
No new scripts. Routing is deterministic; ambiguous intent → ASK the user
before acting (extends the existing ambiguity rule).

## Mode Procedures

### `compare` (read-only)

1. Read the named scope only.
2. Run all 6 detection rules; keep patterns that plausibly fit (smell present
   or near-miss). Drop the rest.
3. Build a matrix per candidate:
   `pattern | why-fits-here | tradeoff | when-NOT (ruled in/out) | fit verdict`.
4. Recommend one + a one-line reason it beats the runner-up. Exact tie of top
   two → state the tie and ASK the user to pick.
5. Output = matrix + recommendation. No code change. May chain into
   `refactor` or `greenfield` if the user says go.

### `follow` (user-triggered scoped scan)

1. Scope = named file + sibling files in the same directory + the nearest
   layer directory (e.g. `services/`). Hard cap; no repo-wide walk. Only on an
   explicit "match existing / make consistent" request (honors reactive rule).
2. Census: which of the 6 patterns already appear in scope; note local
   conventions (naming, DI style, framework idiom in use).
3. Recommendation must conform to the detected convention. If the textbook
   pattern conflicts with house style, follow house style and state the
   deviation explicitly.
4. No pattern detectable in scope → say so; fall back to `suggest`.
5. If the user wants the edit applied, use the existing safety harness.

### `greenfield` (TDD-first)

1. Confirm the target behavior with the user (one question if unclear).
2. Detect language/framework from the nearest project marker to the target
   path.
3. Pick the pattern via `compare` logic (matrix → one).
4. Write a failing test for the behavior first. Run `verify.sh`:
   - Exit `3` (test red) = correct start state, proceed.
   - Exit `0` (already passes) = behavior already exists → reroute to
     `refactor`, do not duplicate.
   - No test could be written (no runner / exit `4`) = abort to
     recommend-only; do not write unverifiable code.
5. `checkpoint.sh`, implement the pattern-correct code, `verify.sh` must reach
   exit `0`. Fail / exit `2` → `rollback.sh`, report first failure, offer one
   retry.
6. Guarantee identical to `refactor`: a test now exists, so the verify router
   applies unchanged.

## Reference Docs

### `references/comparison-rubric.md` (new)

Fixed scoring axes so `compare` is deterministic, not subjective:

- Axes: smell-match strength, change locality (number of sites), reversibility,
  framework-idiom conflict, added-indirection cost.
- Verdict scale: `strong fit` / `partial` / `wrong tool here`.
- Tie-break order: lower indirection, then framework idiom, then fewer touched
  files.
- One worked example (Strategy vs Factory on a typed switch), reused as the
  eval anchor.

### `references/greenfield-tdd.md` (new)

The TDD-first loop. Per-language test-runner cues (pytest / JUnit / xUnit /
PHPUnit / vitest). What a "failing test for not-yet-built behavior" looks like
per pattern. The exit-3-expected gate and the reroute-to-`refactor` rule.
Points back to `safety-harness.md` for checkpoint/rollback.

## SKILL.md Deltas (additive, schema preserved)

- New **Intent routing** section before the Procedure: the 5-mode table +
  "ambiguous → ASK".
- New `## Modes` block: the 3 new procedures (compact, linking to the ref docs).
- Output contract extended: `compare` → matrix + pick; `greenfield` →
  failing-test-first, then changed files or rollback diff.
- `description:` front matter widened to add compare / "match existing
  patterns" / "implement with the right pattern" triggers and the
  Python/Java/C#/PHP languages, so multi-language + the new modes actually
  trigger. Keep the reactive-only wording.
- Existing detection rules, safety steps, and when-NOT cases: untouched.
- No change to `patterns/*.md`, scripts, or existing fixtures.

## Testing

Every change is gated:

- **Regression first:** existing 8 bats + all TS/Python/Java/C#/PHP fixtures
  stay green. The router and new modes are additive; if any existing test
  moves, the design is wrong.
- **`compare`:** new bats — feed `strategy-pos` and a two-pattern-plausible
  fixture; assert the matrix lists the right candidates, recommends the
  expected pattern, and mutates no file.
- **`follow`:** fixture directory with an established convention (e.g. existing
  Repository siblings) plus a new file; assert the recommendation conforms to
  sibling style and the scan never exceeds the scope cap.
- **`greenfield`:** fixture = empty target + behavior spec; assert a failing
  test is written first (verify exit `3` observed), then exit `0`, then the
  behavior is present. Negative: behavior already exists → assert reroute to
  `refactor`, no duplication.
- **Intent routing:** table-driven bats — N request strings → expected mode;
  an ambiguous string asserts ASK and no edit.
- Run per language where cheap; reuse the existing per-ecosystem mock projects.
  Toolchain absent on host → skip with an explicit message, never a silent
  pass.

## Risks / Mitigations

- **Mode misfire** → deterministic router table + ambiguous-must-ASK; routing
  bats covers it.
- **Greenfield safety hole** → TDD-first forces a test to exist before code;
  no test possible = abort to recommend-only.
- **`follow` scope creep** → hard scope cap asserted by test; honors reactive
  rule.
- **Description bloat hurts trigger accuracy** → keep additions tight;
  eval-check trigger precision (skill-creator) post-implementation.
- **Compare subjectivity** → fixed rubric file + worked example as eval anchor.

## Extensibility

A future mode = one row in the intent-routing table + one `## Modes`
subprocedure + (if it mutates code) reuse of the existing safety harness. The
exit-code contract, detection rules, language/framework detection, and the 6
pattern references stay unchanged.

# pattern-surgeon

Reactive TS/JS design-pattern advisor. Point it at a scope; it recommends a
pattern, applies the refactor, and keeps it only if `tsc --noEmit` + tests stay
green. Covers Strategy, Factory, Adapter, Repository, Observer, Dependency
Injection. See `docs/superpowers/specs/2026-05-17-pattern-surgeon-design.md`.

## Docs
- Spec: `docs/superpowers/specs/2026-05-17-pattern-surgeon-design.md`
- Plan: `docs/superpowers/plans/2026-05-17-pattern-surgeon.md`

## Languages
TS/JS · Python · Java (Spring Boot) · C# (.NET Core) · PHP (Laravel).
Verification auto-detects the stack; safety contract identical everywhere.
See `docs/MARKETING.md`.

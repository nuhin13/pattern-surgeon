# pattern-surgeon

Reactive, multi-language design-pattern skill. Point it at a code scope; it
runs one of five modes — `suggest`, `refactor`, `compare`, `follow`,
`greenfield` — over Strategy, Factory, Adapter, Repository, Observer,
Dependency Injection. Code-mutating modes keep changes only if the detected
stack's typecheck + tests stay green (verify-or-revert); `greenfield` is
TDD-first. Reactive only — never scans the repo unprompted. See
`docs/superpowers/specs/2026-05-18-pattern-surgeon-modes-design.md`.

## Docs
- Spec (base): `docs/superpowers/specs/2026-05-17-pattern-surgeon-design.md`
- Spec (multi-language): `docs/superpowers/specs/2026-05-17-pattern-surgeon-multilang-design.md`
- Spec (modes): `docs/superpowers/specs/2026-05-18-pattern-surgeon-modes-design.md`
- Plans: `docs/superpowers/plans/2026-05-17-pattern-surgeon.md`, `docs/superpowers/plans/2026-05-18-pattern-surgeon-modes.md`

## Languages
TS/JS · Python · Java (Spring Boot) · C# (.NET Core) · PHP (Laravel).
Verification auto-detects the stack; safety contract identical everywhere.
See `docs/MARKETING.md`.

# pattern-surgeon

Reactive TS/JS design-pattern advisor. Point it at a scope; it recommends a
pattern, applies the refactor, and keeps it only if `tsc --noEmit` + tests stay
green. Covers Strategy, Factory, Adapter, Repository, Observer, Dependency
Injection. See `docs/superpowers/specs/2026-05-17-pattern-surgeon-design.md`.

# pattern-surgeon Multi-Language Extension — Design Spec

**Date:** 2026-05-17
**Status:** Approved (design); pending implementation plan
**Base branch:** `feat/pattern-surgeon-multilang` (off `feat/pattern-surgeon-impl`)
**Extends:** `docs/superpowers/specs/2026-05-17-pattern-surgeon-design.md`

## Problem

`pattern-surgeon` is TS/JS only. Backend developers work in Python, Java
(Spring Boot), C# (.NET Core), and PHP (Laravel). The original design left an
explicit extensibility seam (router in `verify.sh`, per-language reference
examples). This extension delivers polyglot, framework-aware support without
rewriting the working TS skill.

## Goals

- Support Python, Java, C#, PHP in addition to TS/JS.
- Framework-aware recipes for Spring Boot, Laravel, .NET Core where the
  framework owns the pattern machinery (DI containers, Repository, Factory).
- Preserve the verify-or-revert safety contract (exit `0/2/3/4`) across all
  languages.
- TS path must remain fully green at every phase (no regression).
- Ship a marketing plan (`docs/MARKETING.md`).

## Non-Goals

- No rewrite of the existing TS skill, scripts, or detection rules.
- No new pattern beyond the existing 6.
- No build orchestration / monorepo cross-project resolution beyond detecting
  the edited file's nearest project marker.
- No config-manifest format (router auto-detects; rejected alternative).

## Architecture Delta

The existing skill keeps working; this extends it.

- `scripts/verify.sh`: npm+tsc → **project-marker router**. Exit contract
  unchanged: `0` ok / `2` typecheck / `3` tests / `4` no test.
- `references/patterns/*.md` (6 files): per-language fenced code blocks + a new
  `## Framework idiom` subsection.
- `SKILL.md`: add a **language + framework detection** step before the
  procedure; detection *rules* stay conceptual (language-agnostic).
- `checkpoint.sh` / `rollback.sh`: unchanged (already language-agnostic).
- Fixtures + eval: per-language pos/neg + baseline-red analogs, added per phase.

## verify.sh Router Contract

Detect by nearest project marker to the edited file; run that ecosystem's
typecheck then test. Exit `0/2/3/4` unchanged.

| Marker | Typecheck (→ exit 2 on fail) | Test (→ exit 3 on fail) |
|---|---|---|
| `package.json` (+ `tsconfig.json`) | `tsc --noEmit` | pnpm/yarn/npm `test` |
| `pyproject.toml` / `setup.py` / `requirements.txt` | `mypy` or `pyright` **if configured**, else skip | `pytest` |
| `pom.xml` | `mvn -q compile` | `mvn -q test` |
| `build.gradle`(`.kts`) | `gradle compileJava` | `gradle test` |
| `*.csproj` / `*.sln` | `dotnet build` | `dotnet test` |
| `composer.json` | `phpstan` / `psalm` **if present**, else skip | Laravel → `php artisan test`, else `phpunit` |

Rules:

1. **No static typecheck tool available** (Python without mypy/pyright, PHP
   without phpstan/psalm) → skip the typecheck step, do NOT fail. Behavior
   preservation is guaranteed by tests, which is the real safety property.
   Compiled languages (Java, C#) always have compile = typecheck.
2. **No test runner/target** → exit `4` → SKILL.md legacy path
   (recommend-only). Unchanged behavior.
3. First matching marker wins; on a multi-language repo, verify.sh prints the
   detected stack and scopes to the edited file's project directory.
4. If a required toolchain is absent on the host, verify.sh exits non-zero with
   a clear message — never a silent pass.

## Reference + SKILL.md Changes

**Pattern references (6 files), schema preserved:**

- `Smell signature`: add per-language syntax cues (Java `switch`, PHP `match`,
  C# `switch`, Python `if/elif`).
- `Transform recipe` and `Before / After`: fenced blocks tagged ` ```ts `,
  ` ```python `, ` ```java `, ` ```csharp `, ` ```php `.
- New `## Framework idiom` subsection (after `Transform recipe`), present in
  every pattern file. Content only where a framework changes the correct
  answer:
  - DI: Spring constructor injection / `@Component`; .NET `IServiceCollection`;
    Laravel service container binding.
  - Repository: Spring Data `JpaRepository`; Laravel Eloquent repository; EF
    Core `DbContext`.
  - Factory: Spring `@Bean` / `@Configuration`.
  - Patterns/frameworks without a special idiom state "no framework-specific
    idiom; use the language recipe."
- Schema grep check extended: each pattern file must contain all 5 language
  code fences and the `## Framework idiom` header.

**SKILL.md:** insert a step before the Procedure:

- Detect language by marker file; detect framework (Spring: `spring-boot`
  dependency in pom/gradle; Laravel: `artisan` file + `laravel/framework` in
  composer.json; .NET: `Microsoft.Extensions.DependencyInjection` or
  `Microsoft.AspNetCore` in csproj).
- Add when-NOT: framework owns the machinery → e.g. "Spring/.NET app: do not
  hand-roll a DI container; recommend the framework idiom or suppress."
- The "follow safety-harness" step is unchanged (router is transparent).

## Phasing

Each phase is its own task block with review gates and an independently
shippable commit set.

- **Phase 0 — core:** router `verify.sh` + bats (one minimal mock project per
  ecosystem), reference-schema multi-language upgrade (TS blocks retained,
  other languages stubbed with a clearly-marked placeholder filled in its
  phase), SKILL.md detection step, language-aware eval harness.
- **Phase 1 — Python:** 6 reference Python blocks, fixtures
  `tests/fixtures/py-<pattern>-pos|neg`, `baseline-red-py`, verify.sh Python
  branch bats (pytest, mypy-optional path).
- **Phase 2 — Java + Spring Boot:** Java blocks + Spring `## Framework idiom`,
  Maven and Gradle fixtures, a Spring-pos fixture.
- **Phase 3 — C# / .NET Core:** C# blocks + .NET DI idiom, `dotnet` fixtures.
- **Phase 4 — PHP / Laravel:** PHP blocks + Laravel idiom, composer/phpunit and
  `php artisan test` fixtures.

Stub policy: Phase 0 inserts each non-TS language fence as a single line
`<!-- TODO(phase-N): <lang> example -->` so the schema check can assert
presence; the owning phase replaces it with real code. The final phase removes
the schema check's tolerance for the placeholder (no placeholder may remain
after Phase 4).

## Fixtures

Mirror the existing TS fixture structure per language: a minimal buildable
project, a behavioral test, `pos` exhibits the smell, `neg` is the
"When NOT to apply" case, `baseline-red-<lang>` has no test plus a
compile/type error. Toolchain artifacts (`target/`, `bin/`, `obj/`,
`vendor/`, `__pycache__/`, `.venv/`) are gitignored.

## Testing

- Phase 0 bats use tiny real projects per ecosystem; if a toolchain is absent
  on the host, the test skips with an explicit message — never a silent pass.
- Per phase: schema grep (language blocks present), fixture pos/neg behavioral
  runs, `verify.sh` exit-contract assertions for that marker, an E2E dry run
  for that language.
- Regression gate every phase: existing TS `bats` (8/8) and 12 TS fixtures
  must stay green; the router must not alter the TS path.

## Marketing Plan (deliverable: `docs/MARKETING.md`)

A written go-to-market document, not code:

- **Positioning:** verify-or-revert, polyglot, framework-aware design-pattern
  refactoring — the gap no open-source skill fills (design-pattern advisory was
  the weakest area in the ecosystem research).
- **Channels:** Claude Code plugin marketplaces (obra superpowers-marketplace,
  VoltAgent awesome-agent-skills, ComposioHQ / travisvn awesome lists,
  claudemarketplaces.com, buildwithclaude.com), Show HN, r/programming and
  r/ExperiencedDevs, a dev.to launch post, an X/LinkedIn demo clip.
- **Assets:** README with an asciinema demo, before/after diff GIF per
  language, a comparison table vs SOLID-only skills, an install one-liner.
- **Narrative:** safety (auto-revert), polyglot, framework-aware — with
  concrete metrics (patterns × languages, test-gated).
- **Launch sequence:** tag a release → open marketplace PRs → HN/Reddit/dev.to
  same day → follow-up thread reporting adoption.

## Extensibility

Adding a further language later: add one marker branch in `verify.sh`
(typecheck + test command), add that language's code fences to the 6 pattern
references, add fixtures. The exit-code contract, detection rules, and SKILL.md
procedure stay unchanged.

# follow-repo-ts

Eval anchor for `follow` mode. `repo/` establishes a Repository convention
(`*Repository` class, `byId`, `fetch` confined to the repo layer).
`services/InvoiceService.ts` violates it with a raw `fetch`.

Expected `follow` output: scoped scan (named file + `services/` siblings +
nearest layer) detects the Repository convention; recommendation has `InvoiceService` depend on the existing `OrderRepository`
(reuse the established repo, do NOT introduce a parallel `InvoiceRepository`),
conforming to the existing naming/structure rather than a textbook variant. Scan must not exceed the
scope cap (no repo-wide walk).

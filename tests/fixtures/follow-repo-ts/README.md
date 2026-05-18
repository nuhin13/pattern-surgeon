# follow-repo-ts

Eval anchor for `follow` mode. `repo/UserRepository.ts` and
`repo/OrderRepository.ts` establish a Repository convention (`*Repository`
class, `byId(id)`, `fetch` confined to the repo layer).
`repo/InvoiceRepository.ts` is the named target: it lives in the SAME
directory but violates the convention (bare `getInvoice` function, no class,
no `byId`).

Scope cap check: the target is `repo/InvoiceRepository.ts`; the `follow` scope
cap = named file + sibling files in the same directory + nearest layer. The
convention files are same-directory siblings, so the convention IS detectable
strictly inside the scope cap — no repo-wide walk needed.

Expected `follow` output: detect the sibling Repository convention; recommend
rewriting `InvoiceRepository` as an `InvoiceRepository` class with a
`byId(id)` method and fetch confined to it, matching `UserRepository` /
`OrderRepository` naming and structure. State that the scan stayed within the
scope cap.

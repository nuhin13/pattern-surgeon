# compare-ambiguous-ts

Eval anchor for `compare` mode. The same `switch (kind)` recurs at 3 call
sites (`notifyWelcome`, `notifyReceipt`, `notifyAlert`), so it genuinely meets
the Strategy threshold (same type-switch at ≥2 sites, branches differ only by
algorithm). The conditional `new <X>Notifier()` construction of one family is
scattered across those same 3 places, genuinely meeting the Factory threshold
(family construction in ≥3 places).

Expected `compare` output: a matrix scoring **Strategy** and **Factory** per
`comparison-rubric.md`. Recommend **Strategy** — extracting a strategy map
removes the duplicated algorithm switch at all 3 call sites; Factory alone
would only centralize construction while the per-kind branching stays
duplicated. No code mutation.

# compare-ambiguous-ts

Eval anchor for `compare` mode. `notify` exhibits both a Strategy smell
(switch on type, ≥2 sites, branches differ by behavior) and a Factory smell
(conditional construction of a `Notifier` family).

Expected `compare` output: a matrix scoring **Strategy** and **Factory** per
`comparison-rubric.md`, recommending **Strategy** (it removes the algorithm
branching at all sites; Factory alone would only relocate construction). No
code mutation.

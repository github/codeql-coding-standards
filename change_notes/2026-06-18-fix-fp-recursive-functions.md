`A7-5-2`, `RULE-8-2-10`: `FunctionsCallThemselvesEitherDirectlyOrIndirectly.ql`:
    - Fix false positives where callers of recursive functions were incorrectly reported as recursive. Only calls that participate in a recursive cycle are now reported.

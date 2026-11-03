- Default MISRA C suites now target MISRA C:2025; support remains incomplete.
  Explicit 2023 and 2012 suites retain their guideline sets and query IDs.
- `DIR-4-6` - `PlainIntegerTypeUsedOverExplicitTypedef.ql`:
  - The 2025 query excludes floating-point declarations and aliases.
- `RULE-15-5` - `SinglePointOfExit.ql`:
  - Disapplied by default; recategorization can reactivate the query.
- `RULE-17-6` - `UseOfArrayStatic.ql`:
  - Excluded from 2025 suites; Rule 17.5 array-size contract checks remain enabled.
- Default MISRA C suites now target MISRA C:2025; support remains incomplete.
  Explicit 2023 and 2012 suites retain their guideline sets and query IDs.
- The supported-rules report lists unchanged applicable guidelines under MISRA C:2025
  while retaining their older-edition entries.
- `RULE-15-5` - `SinglePointOfExit.ql`:
  - Disapplied by default; recategorization can reactivate the query.
- When queries share a rule ID, recategorization changes only queries whose default
  category permits the transition. The report lists applicable source categories together.
- `RULE-17-6` - `UseOfArrayStatic.ql`:
  - Excluded from 2025 suites; Rule 17.5 array-size contract checks remain enabled.
- `RULE-21-8` - `TerminationFunctionsOfStdlibhUsed.ql`:
  - Report enabled assertions that call non-returning assertion-failure helpers.
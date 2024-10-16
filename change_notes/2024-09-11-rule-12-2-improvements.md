- `RULE-12-2` - `RightHandOperandOfAShiftRange.ql`:
  - Reduce false positives related to ranges determined by `%=`.
  - Reduce false positives for integer constants with explicit size suffix were incorrectly identified as smaller types.
  - Improve explanation of results, providing additional information on types and size ranges.
  - Combine results stemming from the expansion of a macro, where the result is not dependent on the context.
  
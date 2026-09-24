- `ENV30-C`, `RULE-21-19`, `RULE-25-5-2`: removed duplicate alerts for the same modification of a
  pointer returned by an environment or locale function.
- `RULE-14-3`: loop controlling expressions with an invariant false value are now reported when
  they use the integer literal `0`, including within compound expressions.
- `ARR30-C`: negative out-of-bounds accesses may now produce a result for each reaching buffer
  expression.
- `ARR38-C`, `RULE-21-17`, `RULE-21-18`, `RULE-8-7-1`: corrected the modeling of `strncat` and
  `wcsncat`. Their destination must be null-terminated, while their source does not need a null
  terminator within the specified character limit.

 - `A2-10-1` - `IdentifierHiding.ql`:
   - Improved evaluation performance.
   - Addressed false negatives where nested loops used the same variable name.
   - Exclude cases where a variable declared in a lambda expression shadowed a global or namespace variable that did not appear in the same translation unit.
 - `RULE-5-3` - `IdentifierHidingC.ql`:
   - Improved evaluation performance.
   - Addressed false negatives where nested loops used the same variable name.
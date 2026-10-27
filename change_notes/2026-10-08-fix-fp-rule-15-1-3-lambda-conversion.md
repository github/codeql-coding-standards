- `RULE-15-1-3` - `NonExplicitConversionMember.ql`:
   - Fixed false positives on the compiler-generated conversion operator of a
     captureless lambda's closure type (conversion to a function pointer). This
     operator is implicit by definition and cannot be declared `explicit`.

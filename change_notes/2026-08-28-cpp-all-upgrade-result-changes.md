- `RULE-1-2` - `LanguageExtensionsShouldNotBeUsed.ql`: fixed a false negative where `_Decimal32`,
  `_Decimal64` and `_Decimal128` declarations were no longer reported as compiler extensions.
- `ENV30-C`, `RULE-21-19`, `RULE-25-5-2`: fixed a duplicate alert reported for the same pointer
  write.
- `INT31-C` - `IntegerConversionCausesDataLoss.ql`: fixed a false positive on the standard-permitted
  `(time_t)-1` conversion.
- `RULE-14-3` - `ControllingExprInvariant.ql`: fixed a false negative where a loop's compound
  controlling expression that always evaluates to false was incorrectly permitted.

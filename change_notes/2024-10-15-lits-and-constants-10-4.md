 - `RULE-10-4` - `OperandswithMismatchedEssentialTypeCategory.ql`:
   - Removed false positives where a specified or typedef'd enum type was compared to an enum constant type.
 - `EssentialType` - for all queries related to essential types:
   - `\n` and other control characters are now correctly deduced as essentially char type, instead of an essentially integer type.
   - Enum constants for anonymous enums are now correctly deduced as an essentially signed integer type instead of essentially enum.
- `RULE-7-0-4` - `InappropriateBitwiseOrShiftOperands.ql`:
  - Fixes #1177 - the rule no longer reports operands whose type is not a MISRA numeric type. The
    operand checks used `not isUnsignedType(operandType)`, which is vacuously true for every type
    that has no MISRA numeric type at all, such as class types and the unresolved dependent types
    of uninstantiated template bodies. As a result the rule reported operations that do not use
    the built-in operators, most notably the stream insertion and extraction operators. The checks
    now use `isSignedType(operandType)` instead.
  - Operands of character type, of a non-standard integral type, and of an unscoped enumeration
    type without a fixed underlying type are consequently no longer reported, because none of them
    has a MISRA numeric type. Unscoped enumerations without a fixed underlying type are covered by
    `RULE-10-2-3`.

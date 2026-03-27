/**
 * Provides a configurable module SignedIntegerOverflowShared with a `problems` predicate
 * for the following issue:
 * The multiplication of two signed integers can lead to underflow or overflow and
 * therefore undefined behavior.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Overflow
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

signature module SignedIntegerOverflowSharedConfigSig {
  Query getQuery();
}

module SignedIntegerOverflowShared<SignedIntegerOverflowSharedConfigSig Config> {
  query predicate problems(InterestingOverflowingOperation op, string message) {
    not isExcluded(op, Config::getQuery()) and
    (
      // An operation that returns a signed integer type
      op.getType().getUnderlyingType().(IntegralType).isSigned()
      or
      // The divide or rem expression on a signed integer
      op.(DivOrRemOperation).getDividend().getType().getUnderlyingType().(IntegralType).isSigned()
    ) and
    // Not checked before the operation
    not op.hasValidPreCheck() and
    // Left shift overflow is covered by separate queries (e.g. INT34-C)
    not op instanceof LShiftExpr and
    message =
      "Operation " + op.getOperator() + " of type " + op.getType().getUnderlyingType() +
        " may overflow or underflow."
  }
}

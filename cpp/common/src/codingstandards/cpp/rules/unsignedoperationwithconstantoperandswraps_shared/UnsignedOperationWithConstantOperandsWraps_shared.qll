/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Overflow
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

abstract class UnsignedOperationWithConstantOperandsWraps_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof UnsignedOperationWithConstantOperandsWraps_sharedSharedQuery }

query predicate problems(InterestingOverflowingOperation op, string message) {
  not isExcluded(op, getQuery()) and
  op.getType().getUnderlyingType().(IntegralType).isUnsigned() and
  // Not within a guard condition
  not exists(GuardCondition gc | gc.getAChild*() = op) and
  // Not guarded by a check, where the check is not an invalid overflow check
  not op.hasValidPreCheck() and
  // Is not checked after the operation
  not op.hasValidPostCheck() and
  // Permitted by exception 3
  not op instanceof LShiftExpr and
  // Permitted by exception 2 - zero case is handled in separate query
  not op instanceof DivExpr and
  not op instanceof RemExpr and
  message =
    "Operation " + op.getOperator() + " of type " + op.getType().getUnderlyingType() + " may wrap."
}

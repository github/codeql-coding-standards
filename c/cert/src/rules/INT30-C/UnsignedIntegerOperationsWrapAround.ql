/**
 * @id c/cert/unsigned-integer-operations-wrap-around
 * @name INT30-C: Ensure that unsigned integer operations do not wrap
 * @description Unsigned integer expressions do not strictly overflow, but instead wrap around in a
 *              modular way. If the size of the type is not sufficient, this can happen
 *              unexpectedly.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/int30-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Overflow
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

from InterestingOverflowingOperation op
where
  not isExcluded(op, IntegerOverflowPackage::unsignedIntegerOperationsWrapAroundQuery()) and
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
  not op instanceof RemExpr
select op,
  "Operation " + op.getOperator() + " of type " + op.getType().getUnderlyingType() + " may wrap."

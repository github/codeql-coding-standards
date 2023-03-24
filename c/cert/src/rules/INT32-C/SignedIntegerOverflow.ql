/**
 * @id c/cert/signed-integer-overflow
 * @name INT32-C: Ensure that operations on signed integers do not result in overflow
 * @description The multiplication of two signed integers can lead to underflow or overflow and
 *              therefore undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/int32-c
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
  not isExcluded(op, IntegerOverflowPackage::signedIntegerOverflowQuery()) and
  op.getType().getUnderlyingType().(IntegralType).isSigned() and
  // Not checked before the operation
  not op.hasValidPreCheck() and
  // Not guarded by a check, where the check is not an invalid overflow check
  not op.getAGuardingGVN() = globalValueNumber(op.getAChild*())
select op,
  "Operation " + op.getOperator() + " of type " + op.getType().getUnderlyingType() +
    " may overflow or underflow."

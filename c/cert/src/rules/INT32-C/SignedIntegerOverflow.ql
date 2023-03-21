/**
 * @id c/cert/signed-integer-overflow
 * @name INT32-C: Ensure that operations on signed integers do not result in overflow
 * @description
 * @kind problem
 * @precision high
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

/* TODO: review the table to restrict to only those operations that actually overflow */
from InterestingBinaryOverflowingExpr bop
where
  not isExcluded(bop, IntegerOverflowPackage::signedIntegerOverflowQuery()) and
  bop.getType().getUnderlyingType().(IntegralType).isSigned() and
  // Not checked before the operation
  not bop.hasValidPreCheck() and
  // Not guarded by a check, where the check is not an invalid overflow check
  not bop.getAGuardingGVN() = globalValueNumber(bop.getAChild*())
select bop,
  "Binary expression ..." + bop.getOperator() + "... of type " + bop.getType().getUnderlyingType() +
    " may overflow or underflow."

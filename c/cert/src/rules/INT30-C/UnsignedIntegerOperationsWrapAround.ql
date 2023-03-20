/**
 * @id c/cert/unsigned-integer-operations-wrap-around
 * @name INT30-C: Ensure that unsigned integer operations do not wrap
 * @description Unsigned integer expressions do not strictly overflow, but instead wrap around in a
 *              modular way. If the size of the type is not sufficient, this can happen
 *              unexpectedly.
 * @kind problem
 * @precision high
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

/* TODO: review the table to restrict to only those operations that actually overflow */
from InterestingBinaryOverflowingExpr bop
where
  not isExcluded(bop, IntegerOverflowPackage::unsignedIntegerOperationsWrapAroundQuery()) and
  bop.getType().getUnderlyingType().(IntegralType).isUnsigned() and
  // Not within a guard condition
  not exists(GuardCondition gc | gc.getAChild*() = bop) and
  // Not guarded by a check, where the check is not an invalid overflow check
  not bop.getAGuardingGVN() = globalValueNumber(bop.getAChild*()) and
  // Is not checked after the operation
  not bop.hasPostCheck()
select bop,
  "Binary expression ..." + bop.getOperator() + "... of type " + bop.getType().getUnderlyingType() +
    " may wrap."

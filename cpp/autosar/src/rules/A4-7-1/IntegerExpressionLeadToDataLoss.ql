/**
 * @id cpp/autosar/integer-expression-lead-to-data-loss
 * @name A4-7-1: An integer expression shall not lead to data loss
 * @description Implicit conversions, casts and arithmetic expressions may lead to data loss.
 * @kind problem
 * @precision low
 * @problem.severity warning
 * @tags external/autosar/id/a4-7-1
 *       correctness
 *       external/autosar/strict
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Overflow
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

from InterestingOverflowingOperation e
where
  not isExcluded(e, IntegerConversionPackage::integerExpressionLeadToDataLossQuery()) and
  // Not within a guard condition
  not exists(GuardCondition gc | gc.getAChild*() = e) and
  // Not guarded by a check, where the check is not an invalid overflow check
  not e.hasValidPreCheck() and
  // Covered by `IntMultToLong.ql` instead
  not e instanceof MulExpr and
  // Not covered by this query - overflow/underflow in division is rare
  not e instanceof DivExpr and
  not e instanceof RemExpr
select e, "Binary expression ..." + e.getOperator() + "... may overflow."

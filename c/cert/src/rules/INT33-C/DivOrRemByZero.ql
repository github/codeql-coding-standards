/**
 * @id c/cert/div-or-rem-by-zero
 * @name INT33-C: Ensure that division and remainder operations do not result in divide-by-zero errors
 * @description Dividing or taking the remainder by zero is undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/int33-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Overflow
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

from DivOrRemOperation divOrMod, Expr divisor
where
  not isExcluded(divOrMod, IntegerOverflowPackage::divOrRemByZeroQuery()) and
  divisor = divOrMod.getDivisor() and
  divisor.getType() instanceof IntegralType and
  // Range includes 0
  upperBound(divisor) >= 0 and
  lowerBound(divisor) <= 0 and
  // And an explicit check for 0 does not exist
  not exists(GuardCondition gc, Expr left, Expr right |
    gc.ensuresEq(left, right, 0, divOrMod.getBasicBlock(), false) and
    globalValueNumber(left) = globalValueNumber(divisor) and
    right.getValue().toInt() = 0
  ) and
  // Uninstantiated templates may not have an accurate reflection of the range
  not divOrMod.getEnclosingFunction().isFromUninstantiatedTemplate(_)
select divOrMod,
  "Division or remainder expression with divisor that may be zero (divisor range " +
    lowerBound(divisor) + "..." + upperBound(divisor) + ")."

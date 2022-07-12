/**
 * @id cpp/autosar/divisor-equal-to-zero
 * @name A5-6-1: The right operand of the integer division or remainder operators shall not be equal to zero
 * @description The result is undefined if the right hand operand of the integer division or the
 *              remainder operator is zero.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a5-6-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from BinaryArithmeticOperation bao
where
  not isExcluded(bao, ExpressionsPackage::divisorEqualToZeroQuery()) and
  (bao instanceof DivExpr or bao instanceof RemExpr) and
  bao.getRightOperand().getValue().toFloat() = 0 // `toFloat()` holds for both integer and float literals.
select bao, "Divisor is zero."

/**
 * @id cpp/autosar/increment-and-decrement-operators-mixed-with-other-operators-in-expression
 * @name M5-2-10: The increment (++) and decrement (--) operators shall not be mixed with other operators
 * @description The increment (++) and decrement (--) operators shall not be mixed with other
 *              operators in an expression.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-2-10
 *       readability
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from CrementOperation cop, Operation op, string name
where
  not isExcluded(cop) and
  not isExcluded(op,
    OrderOfEvaluationPackage::incrementAndDecrementOperatorsMixedWithOtherOperatorsInExpressionQuery()) and
  op.getAnOperand() = cop and
  (
    cop instanceof IncrementOperation and
    name = "increment (++)"
    or
    cop instanceof DecrementOperation and
    name = "decrement (++)"
  ) and
  not cop.isInMacroExpansion()
select op, "Mixed use of the $@ operator with the $@ operator.", cop, name, op, op.getOperator()

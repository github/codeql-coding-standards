/**
 * @id cpp/autosar/ternary-operator-condition-not-type-bool
 * @name M5-0-14: The first operand of a conditional-operator shall have type bool
 * @description If an expression with type other than bool is used as the first operand of a
 *              conditional-operator, then its result will be implicitly converted to bool. The
 *              first operand shall contain an explicit test (yielding a result of type bool) in
 *              order to clarify the intentions of the developer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-0-14
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from ConditionalExpr ce
where
  not isExcluded(ce, ExpressionsPackage::ternaryOperatorConditionNotTypeBoolQuery()) and
  not ce.getCondition().getType() instanceof BoolType and
  not ce.isInMacroExpansion()
select ce.getCondition(), "The ternary operator's condition does not have type 'bool'."

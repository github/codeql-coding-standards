/**
 * @id cpp/autosar/insufficient-use-of-parentheses
 * @name M5-0-2: Limited dependence should be placed on C++ operator precedence rules in expressions
 * @description The use of parentheses can be used to emphasize precedence and increase code
 *              readability.
 * @kind problem
 * @precision medium
 * @problem.severity recommendation
 * @tags external/autosar/id/m5-0-2
 *       external/autosar/audit
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from Expr e
where
  not isExcluded(e, OrderOfEvaluationPackage::insufficientUseOfParenthesesQuery())
select e, "Insufficient use of parenthesis in expression."

/**
 * @id cpp/autosar/non-boolean-iteration-condition
 * @name A5-0-2: The condition of an iteration statement shall have type bool
 * @description Non boolean conditions can be confusing for developers.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a5-0-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Loop loopStmt, Expr condition, Type explicitConversionType
where
  not isExcluded(loopStmt, ConditionalsPackage::nonBooleanIterationConditionQuery()) and
  condition = loopStmt.getCondition() and
  explicitConversionType = condition.getExplicitlyConverted().getType().getUnspecifiedType() and
  not explicitConversionType instanceof BoolType
select condition, "Iteration condition has non boolean type " + explicitConversionType + "."

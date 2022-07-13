/**
 * @id cpp/autosar/non-boolean-if-condition
 * @name A5-0-2: The condition of an if-statement shall have type bool
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

from IfStmt ifStmt, Expr condition, Type explicitConversionType
where
  not isExcluded(ifStmt, ConditionalsPackage::nonBooleanIfConditionQuery()) and
  condition = ifStmt.getCondition() and
  not ifStmt.isFromUninstantiatedTemplate(_) and
  explicitConversionType = condition.getExplicitlyConverted().getType().getUnspecifiedType() and
  not explicitConversionType instanceof BoolType
select condition, "If condition has non boolean type " + explicitConversionType + "."

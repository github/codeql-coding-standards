/**
 * @id c/misra/non-boolean-if-condition
 * @name RULE-14-4: The condition of an if-statement shall have type bool
 * @description Non boolean conditions can be confusing for developers.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-14-4
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes

from Expr condition, Type essentialType
where
  not isExcluded(condition, Statements4Package::nonBooleanIfConditionQuery()) and
  exists(IfStmt ifStmt |
    not ifStmt.isFromUninstantiatedTemplate(_) and
    condition = ifStmt.getCondition() and
    essentialType = getEssentialType(ifStmt.getCondition()) and
    not getEssentialTypeCategory(essentialType) = EssentiallyBooleanType()
  )
select condition, "If condition has non boolean essential type " + essentialType + "."

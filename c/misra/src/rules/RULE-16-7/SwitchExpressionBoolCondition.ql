/**
 * @id c/misra/switch-expression-bool-condition
 * @name RULE-16-7: A switch-expression shall not have essentially Boolean type
 * @description An `if-else` construct is more appropriate for boolean controlled expression.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-16-7
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.SwitchStatement

from BooleanSwitchStmt boolSwitch
where not isExcluded(boolSwitch, Statements2Package::switchExpressionBoolConditionQuery())
select boolSwitch, "Boolean expression used in switch."

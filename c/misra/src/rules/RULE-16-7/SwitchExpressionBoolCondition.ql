/**
 * @id c/misra/switch-expression-bool-condition
 * @name RULE-16-7: A switch-expression shall not have essentially Boolean type
 * @description
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-16-7
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.SwitchStatement

from BooleanSwitchStmt switch
where not isExcluded(switch, Statements2Package::switchExpressionBoolConditionQuery())
select switch, "The condition of this $@ statement has boolean type", switch, "switch"

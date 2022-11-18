/**
 * @id c/misra/nest-switch-label-in-switch-statement
 * @name RULE-16-2: A switch label shall only be used when the most closely-enclosing compound statement is the body of
 * @description Nested switch labels cause undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-16-2
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.nestedlabelinswitch.NestedLabelInSwitch

class NestSwitchLabelInSwitchStatementQuery extends NestedLabelInSwitchSharedQuery {
  NestSwitchLabelInSwitchStatementQuery() {
    this = Statements1Package::nestSwitchLabelInSwitchStatementQuery()
  }
}

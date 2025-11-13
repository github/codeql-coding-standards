/**
 * @id c/misra/nest-switch-label-in-switch-statement
 * @name RULE-16-2: Nested switch labels shall not be used
 * @description Nested switch labels can lead to unstructured code.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-16-2
 *       maintainability
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.nestedlabelinswitch.NestedLabelInSwitch

class NestSwitchLabelInSwitchStatementQuery extends NestedLabelInSwitchSharedQuery {
  NestSwitchLabelInSwitchStatementQuery() {
    this = Statements1Package::nestSwitchLabelInSwitchStatementQuery()
  }
}

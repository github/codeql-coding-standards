/**
 * @id c/misra/switch-stmt-not-well-formed
 * @name RULE-16-1: A well formed switch statement should only have expression, compound, selection, iteration or try statements within its body
 * @description The switch statement syntax is weak and may lead to unspecified behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-16-1
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.switchnotwellformed.SwitchNotWellFormed

class SwitchStmtNotWellFormedQuery extends SwitchNotWellFormedSharedQuery {
  SwitchStmtNotWellFormedQuery() {
    this = Statements3Package::switchStmtNotWellFormedQuery()
  }
}

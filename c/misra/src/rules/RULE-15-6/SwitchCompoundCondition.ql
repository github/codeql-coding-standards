/**
 * @id c/misra/switch-compound-condition
 * @name RULE-15-6: The statement forming the body of a switch shall be a compound statement
 * @description If the body of a switch is not enclosed in braces, then this can lead to incorrect
 *              execution, and is hard for developers to maintain.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-15-6
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.SwitchStatement

from SwitchStmt switch
where
  not isExcluded(switch, Statements3Package::switchCompoundConditionQuery()) and
  (
    switch.getStmt() instanceof ArtificialBlock or
    not switch.getStmt() instanceof BlockStmt
  )
select switch, "Switch body not enclosed within braces."

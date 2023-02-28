/**
 * @id c/misra/loop-iteration-condition
 * @name RULE-15-4: There should be no more than one break or goto statement used to terminate any iteration statement
 * @description More than one break or goto statement in iteration conditions may lead to
 *              readability and maintainability issues.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-15-4
 *       maintainability
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from Loop loop
where
  not isExcluded(loop, Statements2Package::loopIterationConditionQuery()) and
  count(Stmt terminationStmt |
    loop.getChildStmt*() = terminationStmt and
    (
      terminationStmt instanceof BreakStmt
      or
      terminationStmt instanceof GotoStmt
    )
  ) > 1
select loop, "$@ statement contains more than one break or goto statement", loop, "Iteration"

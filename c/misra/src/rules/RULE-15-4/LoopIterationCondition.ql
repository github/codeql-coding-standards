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

/**
 * A breaking statement.
 */
class BreakOrGotoStmt extends JumpStmt {
  BreakOrGotoStmt() {
    this instanceof BreakStmt or
    this instanceof GotoStmt
  }

  /**
   * Gets a loop this breaks out of, if any.
   *
   * - This can produce no results if this is a `break` and the enclosing breakable is a switch statement.
   * - This can produce no result if this is a `goto`, and the target is within the same nearest enclosing loop.
   * - This can produce multiple results if this is a `goto`, and the target is outside multiple enclosing loops.
   */
  Loop getABrokenLoop() {
    result = this.(BreakStmt).getBreakable()
    or
    exists(GotoStmt goto |
      goto = this and
      // Find any loop that encloses this goto
      result.getChildStmt*() = goto and
      // But does not enclose the target of the goto i.e. the goto breaks out of it
      not result.getChildStmt*() = goto.getTarget()
    )
  }
}

from Loop loop, BreakOrGotoStmt breakOrGoto
where
  not isExcluded(loop, Statements2Package::loopIterationConditionQuery()) and
  // More than one break or goto statement in the loop
  count(BreakOrGotoStmt terminationStmt | terminationStmt.getABrokenLoop() = loop) > 1 and
  // Report a break or goto statement
  breakOrGoto.getABrokenLoop() = loop
select loop, "Iteration statement contains more than one $@.", breakOrGoto,
  "break or goto statement"

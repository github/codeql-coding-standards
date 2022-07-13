/**
 * @id cpp/autosar/goto-statement-jump-condition
 * @name M6-6-2: The goto statement shall jump to a label declared later in the same function body
 * @description Jumping back to an earlier section in the code can lead to accidental iterations.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-6-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from GotoStmt goto, Stmt target
where
  not isExcluded(goto, ConditionalsPackage::gotoStatementJumpConditionQuery()) and
  target = goto.getTarget() and
  exists(Location targetLoc, Location gotoLoc |
    targetLoc = target.getLocation() and
    gotoLoc = goto.getLocation() and
    targetLoc.getFile() = gotoLoc.getFile()
  |
    // Starts on a previous line
    targetLoc.getStartLine() < gotoLoc.getEndLine()
    or
    // Starts on the same line, but an earlier column
    targetLoc.getStartLine() = gotoLoc.getEndLine() and
    targetLoc.getEndColumn() < gotoLoc.getStartColumn()
  )
select goto, "The goto jumps to the label $@ that is not declared later in the same function.",
  target, goto.getName()

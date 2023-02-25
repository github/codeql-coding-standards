/**
 * @id c/misra/goto-label-block-condition
 * @name RULE-15-3: The goto statement and any of its label shall be declared or enclosed in the same block.
 * @description Any label referenced by a goto statement shall be declared in the same block, or in
 *              any block enclosing the goto statement
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-15-3
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from GotoStmt goto
where
  not isExcluded(goto, Statements2Package::gotoLabelBlockConditionQuery()) and
  not goto.getEnclosingBlock+() = goto.getTarget().getEnclosingBlock()
  or
  exists(SwitchStmt switch, int caseLocation, int nextCaseLocation |
    switch.getAChild*() = goto and
    switch.getASwitchCase().getLocation().getStartLine() = caseLocation and
    switch.getASwitchCase().getNextSwitchCase().getLocation().getStartLine() = nextCaseLocation and
    goto.getLocation().getStartLine() > caseLocation and
    goto.getLocation().getStartLine() < nextCaseLocation and
    (
      goto.getTarget().getLocation().getStartLine() < caseLocation
      or
      goto.getTarget().getLocation().getStartLine() > nextCaseLocation
    ) and
    goto.getTarget().getLocation().getStartLine() > switch.getLocation().getStartLine()
  )
select goto, "The $@ statement and its $@ are not declared or enclosed in the same block.", goto,
  "goto", goto.getTarget(), "label"

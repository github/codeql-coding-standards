/**
 * @id c/misra/goto-label-block-condition
 * @name RULE-15-3: The goto statement and any of its label shall be declared or enclosed in the same block
 * @description Any label referenced by a goto statement shall be declared in the same block, or in
 *              any block enclosing the goto statement.
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

predicate isPartOfSwitch(Stmt goto) {
  exists(SwitchStmt switch | switch.getStmt() = goto.getParent())
}

SwitchCase getSwitchCase(Stmt stmt) {
  exists(int index, SwitchStmt switch |
    getStmtInSwitch(switch, stmt, index) and getStmtInSwitch(switch, result, index - 1)
  )
  or
  exists(int index, SwitchStmt switch, Stmt other |
    getStmtInSwitch(switch, stmt, index) and
    getStmtInSwitch(switch, other, index - 1) and
    not other instanceof SwitchCase and
    result = getSwitchCase(other)
  )
}

predicate getStmtInSwitch(SwitchStmt switch, Stmt s, int index) {
  switch.getStmt().(BlockStmt).getStmt(index) = s
}

int statementDepth(Stmt statement) {
  statement.getParent() = statement.getEnclosingFunction().getBlock() and result = 1
  or
  statementDepth(statement.getParent()) + 1 = result
}

from GotoStmt goto, Stmt target, int gotoDepth, int targetDepth
where
  not isExcluded(goto, Statements2Package::gotoLabelBlockConditionQuery()) and
  goto.getTarget() = target and
  gotoDepth = statementDepth(goto) and
  targetDepth = statementDepth(target) and
  targetDepth >= gotoDepth and
  (
    targetDepth = gotoDepth
    implies
    (
      not isPartOfSwitch(goto) and not goto.getParent() = target.getParent()
      or
      isPartOfSwitch(goto) and not getSwitchCase(goto) = getSwitchCase(target)
    )
  )
select goto, "The $@ statement and its $@ are not declared or enclosed in the same block.", goto,
  "goto", target, "label"

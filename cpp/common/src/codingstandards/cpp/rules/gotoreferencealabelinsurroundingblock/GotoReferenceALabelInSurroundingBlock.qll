/**
 * Provides a library with a `problems` predicate for the following issue:
 * A goto statement shall reference a label in a surrounding block.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class GotoReferenceALabelInSurroundingBlockSharedQuery extends Query { }

Query getQuery() { result instanceof GotoReferenceALabelInSurroundingBlockSharedQuery }

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

query predicate problems(GotoStmt goto, string message, Stmt target, string target_string) {
  not isExcluded(goto, getQuery()) and
  exists(int gotoDepth, int targetDepth |
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
    ) and
    target_string = "label" and
    message = "The goto statement and its $@ are not declared or enclosed in the same block."
  )
}

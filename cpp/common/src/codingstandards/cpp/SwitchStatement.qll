/**
 * Provides a library which includes common components of a well formed switch statement
 */

import cpp

/* A `SwitchCase` that contains a 'SwitchCase' inside its body  */
class NestedSwitchCase extends SwitchCase {
  NestedSwitchCase() {
    exists(SwitchStmt switch, SwitchCase case |
      switch.getASwitchCase() = case and
      this = case.getNextSwitchCase() and
      not this.getParent() = switch.getChildStmt()
    )
  }
}

/* A non-empty `SwitchCase` must terminate in either a throw or break stmt */
class CaseDoesNotTerminate extends SwitchCase {
  CaseDoesNotTerminate() {
    not (
      this.terminatesInBreakStmt() or
      this.terminatesInThrowStmt()
    ) and
    not this.getFollowingStmt() instanceof SwitchCase
  }
}

/* A `SwitchStmt` with condition of boolean type */
class BooleanSwitchStmt extends SwitchStmt {
  BooleanSwitchStmt() { this.getControllingExpr().getType() instanceof BoolType }
}

predicate missingDefaultClause(SwitchStmt switch) {
  not switch.hasDefaultCase() and
  not switch.getControllingExpr().getType() instanceof Enum
}

predicate finalClauseInSwitchNotDefault(SwitchStmt switch) {
  exists(SwitchCase case |
    not case.isDefault() and
    case.getSwitchStmt() = switch and
    case = switch.getDefaultCase().getNextSwitchCase()
  )
}

predicate switchWithCaseNotFirst(SwitchStmt switch) {
  exists(SwitchCase case |
    switch = case.getSwitchStmt() and
    case.getChildNum() = 0 and
    not switch.getStmt().(BlockStmt).getStmt(0) = case
  )
}

/**
 * A switch statement is well formed if the case block only comprises of the following statements:
 * expression_statement
 * compound_statement
 * selection_statement
 * iteration_statement
 * try_block
 */
predicate caseStmtNotWellFormed(Stmt cb) {
  not (
    cb instanceof ExprStmt or // expression statement
    cb instanceof BlockStmt or // compound statement
    cb instanceof ConditionalStmt or // selection statement
    cb instanceof Loop or // iteration statement
    cb instanceof TryStmt // try block
  )
}

predicate switchCaseNotWellFormed(SwitchCase sc) {
  // A statement except the last is not a well-formed "case block".
  exists(Stmt cb | cb = sc.getAStmt() and cb != sc.getLastStmt() | caseStmtNotWellFormed(cb))
  or
  // The final statement is not a break or a throw.
  not sc.terminatesInBreakStmt() and
  not sc.terminatesInThrowStmt() and
  // The case is not empty.
  exists(sc.getAStmt())
}

/**
 * @id cpp/misra/unreachable-statement
 * @name RULE-0-0-1: A function shall not contain unreachable statements
 * @description Dead code can indicate a logic error, potentially introduced during code edits, or
 *              it may be unnecessary code that can be deleted.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-0-0-1
 *       maintainability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.deadcode.UnreachableCode
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.ExceptionSpecifications
import codingstandards.cpp.exceptions.Shadowing

/**
 * MISRA C++ defines its own notion of unreachable statements, which is similar to, but distinct
 * from, the general concept of unreachable code.
 *
 * This is not a superset of `BasicBlock.isReachable()`, because that includes all catch blocks.
 * However, it is a superset of the transitive closure of blocks reachable from function entry via
 * `getASuccessor`.
 *
 * The superset relationship can be read below, with extra reachable cases added for `&&`, `||`,
 * `?:`, and `constexpr if`, and catch blocks that aren't shadowed by prior catch blocks.
 */
predicate isReachable(BasicBlock bb) {
  bb = any(Function f).getEntryPoint()
  or
  isReachable(bb.getAPredecessor())
  or
  exists(BinaryLogicalOperation op |
    isReachable(op.getBasicBlock()) and
    bb = op.getAnOperand().getBasicBlock()
  )
  or
  exists(ConditionalExpr cond |
    isReachable(cond.getBasicBlock()) and
    bb = [cond.getThen(), cond.getElse()].getBasicBlock()
  )
  or
  exists(FunctionCall call, TryStmt try, CatchBlock cb |
    isReachable(call.getBasicBlock()) and
    not isNoExceptTrue(call.getTarget()) and
    try = getNearestTry(call.getEnclosingStmt()) and
    cb = try.getACatchClause() and
    not cb instanceof ShadowedCatchBlock and
    bb = cb.getBasicBlock()
  )
  or
  exists(ConstexprIfStmt ifStmt |
    isReachable(ifStmt.getBasicBlock()) and
    bb = [ifStmt.getThen(), ifStmt.getElse()].getBasicBlock()
  )
}

/**
 * Holds if `bb` is an orphan basic block that is disconnected from the CFG and
 * does not represent a statement. These are artifacts of the extractor/CFG
 * construction (e.g., variable access expressions, function name nodes, or
 * temporary object reuse nodes) and not genuine unreachable statements.
 * A block with no predecessors that is a Stmt is legitimately unreachable code
 * (e.g., code after an infinite loop or noreturn call).
 */
predicate isDisconnectedNonStmtBlock(BasicBlock bb) {
  not exists(bb.getAPredecessor()) and
  not exists(bb.getASuccessor()) and
  not bb = any(Function f).getEntryPoint() and
  not bb instanceof Stmt
}

from BasicBlock bb
where
  not isExcluded(bb, DeadCode3Package::unreachableStatementQuery()) and
  not isReachable(bb) and
  not isCompilerGenerated(bb) and
  not affectedByMacro(bb) and
  not isDisconnectedNonStmtBlock(bb)
// Note that the location of a BasicBlock will in some cases have an incorrect end location, often
// preceding the end and including live code. We cast the block to an `Element` to get locations
// that are not broken.
select bb.(Element), "Unreachable statement in function '$@'.", bb.getEnclosingFunction(),
  bb.getEnclosingFunction().getName()

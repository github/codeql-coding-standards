/**
 * Provides a library for working with for loops.
 */

import cpp
import Operator

// ******* COPIED FROM semmle.code.cpp.Iteration ******* //
/**
 * Holds if `child` is in the condition `forCondition` of a 'for'
 * statement.
 *
 * For example, if a program includes
 * ```
 * for (i = 0; i < 10; i++) { j++; }
 * ```
 * then this predicate will hold with `forCondition` as `i < 10`,
 * and `child` as any of `i`, `10` and `i < 10`.
 */
pragma[noopt]
private predicate inForCondition(Expr forCondition, Expr child) {
  exists(ForStmt for |
    forCondition = for.getCondition() and
    child = forCondition and
    for instanceof ForStmt
  )
  or
  exists(Expr mid |
    inForCondition(forCondition, mid) and
    child.getParent() = mid
  )
}

// ******* COPIED FROM semmle.code.cpp.Iteration ******* //
/**
 * Holds if `child` is in the update `forUpdate` of a 'for' statement.
 *
 * For example, if a program includes
 * ```
 * for (i = 0; i < 10; i += 1) { j++; }
 * ```
 * then this predicate will hold with `forUpdate` as `i += 1`,
 * and `child` as any of `i`, `1` and `i += 1`.
 */
pragma[noopt]
private predicate inForUpdate(Expr forUpdate, Expr child) {
  exists(ForStmt for | forUpdate = for.getUpdate() and child = forUpdate)
  or
  exists(Expr mid | inForUpdate(forUpdate, mid) and child.getParent() = mid)
}

class MemberCrementOperation extends FunctionCall {
  MemberCrementOperation() { this.getTarget() instanceof UserCrementOperator }

  Expr getOperand() { result = this.getQualifier() }
}

class MemberAssignmentOperation extends FunctionCall {
  MemberAssignmentOperation() { this.getTarget() instanceof AssignmentOperator }

  Expr getLValue() { result = this.getQualifier() }

  string getOperator() { result = this.getTarget().getName().regexpCapture("operator(.+)", 1) }
}

/**
 * Gets a LoopCounter for the given `ForStmt`.
 *
 * Equivalent to ForStmt.getAnIterationVariable(), but handles += and -= as well.
 */
pragma[noopt]
Variable getALoopCounter(ForStmt fs) {
  // ------------------------------------------------------------------------------------------------
  // NOTE: This is an updated version of ForStmt.getAnIterationVariable(), handling additional cases.
  //       The use of pragma[noopt] is retained from the original code, as we haven't determined
  //       whether it's still necessary across a broad range of databases. As a noopt predicate, it
  //       includes a degree of duplication as the join order is defined based on the order of the
  //       conditions.
  // ------------------------------------------------------------------------------------------------
  // check that it is assigned to, incremented or decremented in the update
  exists(Expr updateOpRoot, Expr updateOp |
    updateOpRoot = fs.getUpdate() and
    inForUpdate(updateOpRoot, updateOp)
  |
    exists(CrementOperation op, VariableAccess va |
      op = updateOp and
      op instanceof CrementOperation and
      op.getOperand() = va and
      va = result.getAnAccess()
    )
    or
    exists(MemberCrementOperation op, VariableAccess va |
      op = updateOp and
      op instanceof MemberCrementOperation and
      op.getOperand() = va and
      va = result.getAnAccess()
    )
    or
    exists(MemberAssignmentOperation op, VariableAccess va |
      op = updateOp and
      op instanceof MemberAssignmentOperation and
      op.getOperator() = ["+=", "-="] and
      op.getLValue() = va and
      va = result.getAnAccess()
    )
    or
    exists(AssignArithmeticOperation op, VariableAccess va |
      op = updateOp and
      op instanceof AssignArithmeticOperation and
      op.getOperator() = ["+=", "-="] and
      op.getLValue() = va and
      va = result.getAnAccess()
    )
    or
    updateOp = result.getAnAssignedValue()
    or
    // updateOp is an access whose address is taken in a non-const way
    exists(FunctionCall fc, VariableAccess va |
      fc = updateOp and
      fc instanceof FunctionCall and
      fc.getAnArgument() = va and
      va = result.getAnAccess() and
      va.isAddressOfAccessNonConst()
    )
  ) and
  result instanceof Variable and
  // checked or used in the condition
  exists(Expr e, VariableAccess va |
    va = result.getAnAccess() and
    inForCondition(e, va) and
    e = fs.getCondition()
  )
}

/**
 * Gets an iteration variable as identified by the initialization statement for the loop.
 */
Variable getAnIterationVariable(ForStmt forLoop) {
  // This differs from the `ForStmt.getAnIterationVariable` definition because MISRA has a looser
  // definition of iteration variables.
  result = forLoop.getInitialization().(DeclStmt).getADeclaration()
  or
  result.getAnAssignment() = forLoop.getInitialization().(ExprStmt).getExpr()
}

/**
 * Holds if for loop `forLoop` contains more than one loop counter.
 * M6-5-1 and A6-5-2
 */
predicate isForLoopWithMulipleCounters(ForStmt forLoop) {
  count(LoopCounter c | c.getALoop() = forLoop) > 1
}

/**
 * Holds if for loop `forLoop` contains floating-point type counters.
 * M6-5-1 and A6-5-2
 */
predicate isForLoopWithFloatingPointCounters(ForStmt forLoop, Variable v) {
  v = getAnIterationVariable(forLoop) and
  v.getType() instanceof FloatingPointType
}

/**
 * Holds if for loop `forLoop` contains an invalid for loop incrementation.
 * M6-5-2
 */
predicate isInvalidForLoopIncrementation(ForStmt forLoop, Variable v, VariableAccess modification) {
  v = getAnIterationVariable(forLoop) and
  modification = v.getAnAccess() and
  modification = forLoop.getUpdate().getAChild*() and
  // Is modified
  (
    // Variable directly modified
    modification.isModified()
    or
    // Has a call to a member function on the variable, where the target is non-const,
    // i.e. can modify the state of the object
    exists(Call c |
      c.getQualifier() = modification and
      not c.getTarget() instanceof ConstMemberFunction
    )
  ) and
  // And not by a call to a crement operator
  not exists(CrementOperation cop | cop.getOperand() = modification) and
  not exists(Call c |
    c.getQualifier() = modification and c.getTarget() instanceof UserCrementOperator
  ) and
  exists(VariableAccess va | va = forLoop.getCondition().getAChild*() and va = v.getAnAccess() |
    exists(EqualityOperation eop | eop.getAnOperand() = va)
    or
    exists(Call call |
      call.getTarget() instanceof UserEqualityOperator and
      [call.getQualifier(), call.getArgument(0)] = va
    )
  )
}

/**
 * Holds if for loop `forLoop` modifies loop counters inside the condition.
 * M6-5-3
 */
predicate isLoopCounterModifiedInCondition(ForStmt forLoop, VariableAccess loopCounterAccess) {
  loopCounterAccess = forLoop.getCondition().getAChild+() and
  loopCounterAccess = getAnIterationVariable(forLoop).getAnAccess() and
  (
    loopCounterAccess.isModified() or
    loopCounterAccess.isAddressOfAccessNonConst()
  )
}

/**
 * Holds if for loop `forLoop` that have had loop counters modified inside the statement.
 * M6-5-3
 */
predicate isLoopCounterModifiedInStatement(
  ForStmt forLoop, Variable loopCounter, VariableAccess loopCounterAccess
) {
  loopCounter = getAnIterationVariable(forLoop) and
  loopCounterAccess = loopCounter.getAnAccess() and
  (
    loopCounterAccess.isModified() or
    loopCounterAccess.isAddressOfAccessNonConst()
  ) and
  forLoop.getStmt().getChildStmt*() = loopCounterAccess.getEnclosingStmt()
}

/**
 * Holds if for loop `forLoop` terminates nondeterministically.
 * M6-5-4
 */
predicate isIrregularLoopCounterModification(
  ForStmt forLoop, Variable loopCounter, VariableAccess loopCounterAccess
) {
  // get a loop counter of Integer type
  loopCounter = getAnIterationVariable(forLoop) and
  loopCounter.getType() instanceof IntegralType and
  loopCounter.getAnAccess() = loopCounterAccess and
  // match any modified loop counter access in the update of a for loop
  loopCounterAccess = forLoop.getUpdate().getAChild*() and
  loopCounterAccess.isModified() and
  // exclude crement operations
  not loopCounterAccess = any(CrementOperation co).getOperand() and
  // exclude += n and -= n, provided n is constant
  not exists(AssignArithmeticOperation aop |
    (aop instanceof AssignSubExpr or aop instanceof AssignAddExpr) and
    aop.getLValue() = loopCounterAccess
  |
    aop.getRValue().isConstant()
    or
    exists(Variable n |
      aop.getRValue() = n.getAnAccess() and
      not exists(VariableAccess na |
        na = n.getAnAccess() and
        na.isModified()
      |
        // n is not constant if n is updated in the body, condition or update of the for loop
        forLoop.getStmt().getAChild*() = na.getEnclosingStmt()
        or
        forLoop.getCondition().getAChild*() = na
        or
        forLoop.getUpdate().getAChild*() = na
      )
    )
  )
}

/**
 * Holds if for loop `forLoop`'s loop-control-variables `loopControlVariable` is modified in the loop condition through access `loopControlVariableAccess`.
 * M6-5-5
 */
predicate isLoopControlVarModifiedInLoopCondition(
  ForStmt forLoop, LoopControlVariable loopControlVariable, VariableAccess loopControlVariableAccess
) {
  loopControlVariableAccess = loopControlVariable.getVariableAccessInLoop(forLoop) and
  not loopControlVariable = getAnIterationVariable(forLoop) and
  loopControlVariableAccess = forLoop.getCondition().getAChild+() and
  (
    loopControlVariableAccess.isModified() or
    loopControlVariableAccess.isAddressOfAccessNonConst()
  )
}

/**
 * Holds if for loop `forLoop`'s loop-control-variables `loopControlVariable` is modified in the loop expression through access `loopControlVariableAccess`
 * M6-5-5
 */
predicate isLoopControlVarModifiedInLoopExpr(
  ForStmt forLoop, LoopControlVariable loopControlVariable, VariableAccess loopControlVariableAccess
) {
  loopControlVariableAccess = loopControlVariable.getVariableAccessInLoop(forLoop) and
  // Not a standard loop counter for this loop
  not loopControlVariable = getALoopCounter(forLoop) and
  loopControlVariableAccess = forLoop.getUpdate().getAChild() and
  (
    loopControlVariableAccess.isModified() or
    loopControlVariableAccess.isAddressOfAccessNonConst()
  )
}

/**
 * Holds if for loop `forLoops`'s loop control variable `loopControlVariable` modified in a statement through access `loopControlVariableAccess` and
 * the type of the control variable is not a boolean.
 * M6-5-6
 */
predicate isNonBoolLoopControlVar(
  ForStmt forLoop, LoopControlVariable loopControlVariable, VariableAccess loopControlVariableAccess
) {
  exists(Variable loopCounter, ComparisonOperation terminationCheck |
    loopCounter = getAnIterationVariable(forLoop) and
    forLoop.getCondition() = terminationCheck.getParent*()
  |
    // get a loop control variable that is not a loop counter
    loopControlVariableAccess = loopControlVariable.getVariableAccessInLoop(forLoop) and
    not loopControlVariable = getAnIterationVariable(forLoop) and
    // filter only loop control variables that are modified
    (
      loopControlVariableAccess.isModified() or
      loopControlVariableAccess.isAddressOfAccess()
    ) and
    // check if the variable type is anything but bool
    not loopControlVariable.getType() instanceof BoolType and
    // check if the control variable is part of the termination check, but is not compared to the loop counter
    terminationCheck.getAnOperand() = loopControlVariable.getAnAccess().getParent*() and
    not terminationCheck.getAnOperand() = loopCounter.getAnAccess().getParent*()
  )
}

predicate isInvalidLoop(ForStmt forLoop) { isInvalidLoop(forLoop, _, _, _) }

predicate isInvalidLoop(ForStmt forLoop, string reason, Locatable reasonLocation, string reasonLabel) {
  exists(Variable loopCounter |
    isInvalidForLoopIncrementation(forLoop, loopCounter, reasonLocation) and
    reason =
      "it $@ its loop counter '" + loopCounter.getName() +
        "' with an operation that is not an increment or decrement" and
    reasonLabel = "updates"
  )
  or
  isForLoopWithMulipleCounters(forLoop) and
  reason = "it uses multiple loop counters$@" and
  reasonLabel = "" and
  reasonLocation.getLocation() instanceof UnknownExprLocation
  or
  isForLoopWithFloatingPointCounters(forLoop, reasonLocation) and
  reason = "it uses a loop counter '$@' of type floating-point" and
  reasonLabel = reasonLocation.(Variable).getName()
  or
  isLoopCounterModifiedInCondition(forLoop, reasonLocation) and
  reason =
    "it $@ the loop counter '" + reasonLocation.(VariableAccess).getTarget().getName() +
      "' in the condition" and
  reasonLabel = "updates"
  or
  exists(Variable loopCounter |
    isLoopCounterModifiedInStatement(forLoop, loopCounter, reasonLocation) and
    reason = "it $@ the loop counter '" + loopCounter.getName() + "' in the body of the loop" and
    reasonLabel = "updates"
  )
  or
  exists(Variable loopCounter |
    isIrregularLoopCounterModification(forLoop, loopCounter, reasonLocation) and
    reason = "it $@ the loop counter '" + loopCounter.getName() + "' irregularly" and
    reasonLabel = "updates"
  )
  or
  exists(Variable loopControlVariable |
    isLoopControlVarModifiedInLoopExpr(forLoop, loopControlVariable, reasonLocation) and
    reason =
      "it updates $@, a loop control variable other than the loop counter, in the update expression of the loop" and
    reasonLabel = loopControlVariable.getName()
  )
  or
  isNonBoolLoopControlVar(forLoop, reasonLocation, _) and
  reason = "its $@ is not a boolean" and
  reasonLabel = "loop control variable"
}

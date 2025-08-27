/**
 * @id cpp/misra/legacy-for-statements-should-be-simple
 * @name RULE-9-5-1: Legacy for statements should be simple
 * @description Legacy for statements with complex initialization, condition, and increment
 *              expressions can be difficult to understand and maintain. Simple for loops are more
 *              readable.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-9-5-1
 *       maintainability
 *       readability
 *       external/misra/allocated-target/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

/**
 * A comparison expression that has the minimum qualification as being a valid termination
 * condition of a legacy for-loop. It is characterized by a value read from a variable being
 * compared to a value, which is supposed to be the loop bound.
 */
class LegacyForLoopCondition extends RelationalOperation {
  ForStmt forLoop;
  VariableAccess loopCounter;
  Expr loopBound;

  LegacyForLoopCondition() {
    loopCounter = this.getAnOperand() and
    loopBound = this.getAnOperand() and
    loopCounter.getTarget() = forLoop.getInitialization().(DeclStmt).getADeclaration() and
    loopBound != loopCounter
  }

  VariableAccess getLoopCounter() { result = loopCounter }

  Expr getLoopBound() { result = loopBound }
}

/**
 * Holds if the given expression is impure and contains an access to the variable, and
 * thus may mutate the variable.
 *
 * Note that this relation over-approximates and might include impure expressions that
 * in fact do not mutate the variable.
 */
predicate exprWithVarAccessMaybeImpure(Expr expr, Variable variable) {
  exists(VariableAccess varAccess |
    expr.mayBeImpure() and
    expr.getAChild*() = varAccess and
    variable = varAccess.getTarget()
  )
}

/**
 * Gets the loop step of a legacy for loop.
 *
 * This predicate assumes the update expression of the given for loop is an add-and-assign
 * (`+=`) or sub-and-assign (`-=`) expression, so the update expression that is an increment
 * (`++`) or a decrement (`--`) operation should be handled using different means than this
 * predicate.
 */
Expr getLoopStepOfForStmt(ForStmt forLoop) {
  result = forLoop.getUpdate().(AssignAddExpr).getRValue() or
  result = forLoop.getUpdate().(AssignSubExpr).getRValue()
}

/**
 * Holds if the given function has as parameter at a given index a pointer to a
 * constant value or a reference of a constant value.
 */
predicate functionHasConstPointerOrReferenceParameter(Function function, int index) {
  function.getParameter(index).getType().(PointerType).getBaseType().isConst() or
  function.getParameter(index).getType().(ReferenceType).getBaseType().isConst()
}

/**
 * Holds if the the variable behind a given variable access is taken its address
 * in a declaration in either the body of the for-loop or in its update expression.
 *
 * e.g.1. The loop counter variable `i` in the body is taken its address in the
 * declaration of a pointer variable `m`.
 * ``` C++
 * for (int i = 0; i < k; i += l) {
 *   int *m = &i;
 * }
 * ```
 * e.g.2. The loop bound variable `k` in the body is taken its address in the
 * declaration of a pointer variable `m`.
 * ``` C++
 * for (int i = j; i < k; i += l) {
 *   int *m = &k;
 * }
 * ```
 */
predicate variableAddressTakenInDeclaration(ForStmt forLoop, VariableAccess baseVariableAccess) {
  exists(AddressOfExpr addressOfExpr, DeclStmt decl |
    decl.getParentStmt+() = forLoop and
    decl.getADeclarationEntry().(VariableDeclarationEntry).getVariable().getInitializer().getExpr() =
      addressOfExpr and
    baseVariableAccess.getTarget() =
      forLoop.getCondition().(LegacyForLoopCondition).getLoopBound().(VariableAccess).getTarget()
  )
}

/**
 * Holds if the the variable behind a given variable access is taken its address
 * as an argument of a call in either the body of the for-loop or in its update
 * expression.
 *
 * e.g.1. The loop counter variable `i` in the body is taken its address in the
 * declaration of a pointer variable `m`.
 * ``` C++
 * for (int i = 0; i < k; i += l) {
 *   g(&i);
 * }
 * ```
 * e.g.2. The loop bound variable `k` in the body is taken its address in the
 * declaration of a pointer variable `m`.
 * ``` C++
 * for (int i = j; i < k; i += l) {
 *   g(&k);
 * }
 * ```
 */
predicate variableAddressTakenAsConstArgument(
  ForStmt forLoop, VariableAccess baseVariableAccess, Call call
) {
  exists(AddressOfExpr addressOfExpr, int index |
    call.getParent+() = forLoop.getAChild+() and
    call.getArgument(index).getAChild*() = addressOfExpr and
    functionHasConstPointerOrReferenceParameter(call.getTarget(), index) and
    addressOfExpr.getOperand() = baseVariableAccess.getTarget().getAnAccess()
  )
}

/**
 * Holds if the the variable behind a given variable access is taken its address
 * as an argument of a complex expression in either the body of the for-loop or
 * in its update expression.
 *
 * e.g. The loop counter variable `i` in the body and the loop bound variable `k`
 * is taken its address in a compound expression.
 * ``` C++
 * for (int i = 0; i < k; i += l) {
 *   *(cond ? &i : &k) += 1;
 * }
 * ```
 */
predicate variableAddressTakenInExpression(ForStmt forLoop, VariableAccess baseVariableAccess) {
  exists(AddressOfExpr addressOfExpr |
    baseVariableAccess.getParent+() = forLoop.getAChild+() and
    addressOfExpr.getParent+() = forLoop.getAChild+() and
    addressOfExpr.getOperand() = baseVariableAccess.getTarget().getAnAccess()
  ) and
  not exists(Call call | variableAddressTakenAsConstArgument(forLoop, baseVariableAccess, call))
}

from ForStmt forLoop
where
  not isExcluded(forLoop, StatementsPackage::legacyForStatementsShouldBeSimpleQuery()) and
  /* 1. There is a counter variable that is not of an integer type. */
  exists(Type type | type = forLoop.getAnIterationVariable().getType() |
    not (
      type instanceof IntegralType or
      type instanceof FixedWidthIntegralType
    )
  )
  or
  /*
   * 2. The loop condition checks termination without comparing the counter variable and the
   * loop bound using a relational operator.
   */

  not forLoop.getCondition() instanceof LegacyForLoopCondition
  or
  /* 3. The loop counter is mutated somewhere other than its update expression. */
  exists(Expr mutatingExpr, Variable loopCounter |
    mutatingExpr = forLoop.getStmt().getChildStmt().getAChild() and
    loopCounter = forLoop.getAnIterationVariable()
  |
    exprWithVarAccessMaybeImpure(mutatingExpr, loopCounter)
  )
  or
  /* 4. The type size of the loop counter is not greater or equal to that of the loop counter. */
  exists(LegacyForLoopCondition forLoopCondition | forLoopCondition = forLoop.getCondition() |
    exists(Type loopCounterType, Type loopBoundType |
      loopCounterType = forLoopCondition.getLoopCounter().getType() and
      loopBoundType = forLoopCondition.getLoopBound().getType()
    |
      loopCounterType.getSize() < loopBoundType.getSize()
    )
  )
  or
  /* 5. The loop bound and the loop step is a variable that is mutated in the for loop. */
  exists(Expr mutatingExpr |
    (
      /* 1. The mutating expression may be in the loop body. */
      mutatingExpr = forLoop.getStmt().getChildStmt().getAChild*()
      or
      /* 2. The mutating expression may be in the loop updating expression. */
      mutatingExpr = forLoop.getUpdate().getAChild*()
    )
  |
    /* 5-1. The mutating expression mutates the loop bound. */
    exists(LegacyForLoopCondition forLoopCondition, Variable loopBoundVariable |
      forLoopCondition = forLoop.getCondition() and
      loopBoundVariable = forLoopCondition.getLoopBound().(VariableAccess).getTarget()
    |
      exprWithVarAccessMaybeImpure(mutatingExpr, loopBoundVariable)
    )
    or
    /* 5-2. The mutating expression mutates the loop step. */
    exists(VariableAccess loopStep | loopStep = getLoopStepOfForStmt(forLoop) |
      exprWithVarAccessMaybeImpure(mutatingExpr, loopStep.getTarget())
    )
  )
  or
  /*
   * 6. Any of the loop counter, loop bound, or a loop step is taken as a mutable reference
   * or its address to a mutable pointer.
   */

  /* 6-1. The loop counter is taken a mutable reference or its address to a mutable pointer. */
  variableAddressTakenInDeclaration(forLoop,
    forLoop.getCondition().(LegacyForLoopCondition).getLoopCounter())
  or
  /* 6-2. The loop bound is taken a mutable reference or its address to a mutable pointer. */
  none()
  or
  /* 6-3. The loop step is taken a mutable reference or its address to a mutable pointer. */
  none()
select forLoop, "TODO"

private module Notebook {
  private predicate test(Function function) {
    function.getParameter(_).getType().(PointerType).getBaseType().isConst() or
    function.getParameter(_).getType().(ReferenceType).getBaseType().isConst()
  }

  private predicate test2(Expr expr, string qlClasses) {
    expr.getType().isConst() and
    qlClasses = expr.getPrimaryQlClasses()
  }

  private predicate test3(Function function, string qlClasses) {
    qlClasses = function.getParameter(_).getType().getAQlClass()
  }
}

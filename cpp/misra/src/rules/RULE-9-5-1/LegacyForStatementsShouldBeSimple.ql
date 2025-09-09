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
  /**
   * The legacy for-loop this relational operation is a condition of.
   */
  ForStmt forLoop;
  VariableAccess loopCounter;
  Expr loopBound;

  LegacyForLoopCondition() {
    loopCounter = this.getAnOperand() and
    loopBound = this.getAnOperand() and
    loopCounter.getTarget() = forLoop.getInitialization().(DeclStmt).getADeclaration() and
    loopBound != loopCounter
  }

  /**
   * Gets the variable access to the loop counter variable, embedded in this loop condition.
   */
  VariableAccess getLoopCounter() { result = loopCounter }

  /**
   * Gets the variable access to the loop bound variable, embedded in this loop condition.
   */
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
 * Holds if the given function has as parameter a pointer to a constant
 * value, at a given index.
 */
private predicate functionHasConstPointerParameter(Function function, int index) {
  function.getParameter(index).getType().(PointerType).getBaseType().isConst()
}

/**
 * Holds if the variable behind a given variable access is taken its address in
 * a non-const variable declaration, in the body of the for-loop.
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
predicate variableAddressTakenInNonConstDeclaration(
  ForStmt forLoop, VariableAccess baseVariableAccess
) {
  exists(AddressOfExpr addressOfExpr, DeclStmt decl |
    decl.getParentStmt+() = forLoop and
    decl.getADeclarationEntry().(VariableDeclarationEntry).getVariable().getInitializer().getExpr() =
      addressOfExpr and
    addressOfExpr.getOperand() = baseVariableAccess and
    not decl.getADeclarationEntry()
        .(VariableDeclarationEntry)
        .getVariable()
        .getType()
        .(PointerType)
        .getBaseType()
        .isConst()
  )
}

/**
 * Holds if the variable behind a given variable access is taken its address
 * as an argument of a call in either the body of the for-loop or in its update
 * expression.
 *
 * e.g.1. The address of the loop counter variable `i` is passed as argument
 * to the call to `g`.
 * ``` C++
 * void g1(int *x);
 *
 * for (int i = 0; i < k; i += l) {
 *   g1(&i);
 * }
 * ```
 * e.g.2. The address of the loop counter variable `k` is passed as argument
 * to the call to `g`.
 * ``` C++
 * void g1(int *x);
 *
 * for (int i = j; i < k; i += l) {
 *   g1(&k);
 * }
 * ```
 */
private predicate variableAddressTakenAsConstArgument(
  ForStmt forLoop, VariableAccess baseVariableAccess, Call call
) {
  exists(AddressOfExpr addressOfExpr, int index |
    call.getParent+() = forLoop.getAChild+() and // TODO: Bad
    call.getArgument(index).getAChild*() = addressOfExpr and
    exists(PointerType parameterType |
      parameterType = call.getTarget().getParameter(index).getType() and
      not parameterType.getBaseType().isConst()
    ) and
    addressOfExpr.getOperand() = baseVariableAccess.getTarget().getAnAccess() and
    baseVariableAccess.getParent+() = forLoop
  )
}

/**
 * Holds if the variable behind a given variable access is taken its address
 * as an argument of a complex expression in either the body of the for-loop or
 * in its update expression.
 *
 * e.g.1. The loop counter variable `i` in the body and the loop bound variable `k`
 * is taken its address in a call.
 * ``` C++
 * void g1(int *x);
 *
 * for (int i = j; i < k; i += l) {
 *   g1(&i);
 * }
 * ```
 * e.g.2. The loop counter variable `i` in the body and the loop bound variable `k`
 * is taken its address in a compound expression.
 * ``` C++
 * for (int i = 0; i < k; i += l) {
 *   *(cond ? &i : &k) += 1;
 * }
 * ```
 */
/* TODO: Do we need to use Expr.getUnderlyingType() to ensure that the expression is non-const? */
predicate variableAddressTakenInExpression(ForStmt forLoop, VariableAccess baseVariableAccess) {
  exists(AddressOfExpr addressOfExpr |
    baseVariableAccess.getParent+() = forLoop.getAChild+() and // TODO: Bad
    addressOfExpr.getParent+() = forLoop.getAChild+() and
    addressOfExpr.getOperand() = baseVariableAccess.getTarget().getAnAccess()
  )
}

/**
 * Holds if the variable behind a given variable access is taken its reference
 * in a non-const variable declaration, in the body of the for-loop.
 *
 * e.g.1. The loop counter variable `i` in the body is taken its reference in
 * the declaration of a variable `m`.
 * ``` C++
 * for (int i = j; i < k; i += l) {
 *   int &m = i;
 * }
 * ```
 * e.g.2. The loop bound variable `k` in the body is taken its reference in the
 * declaration of a variable `m`.
 * ``` C++
 * for (int i = j; i < k; i += l) {
 *   int &m = k;
 * }
 * ```
 */
predicate variableReferenceTakenInNonConstDeclaration(
  ForStmt forLoop, VariableAccess baseVariableAccess
) {
  exists(DeclStmt decl, Variable definedVariable, ReferenceType definedVariableType |
    decl.getParentStmt+() = forLoop and
    not decl = forLoop.getInitialization() and // Exclude the for-loop counter initialization.
    definedVariable = decl.getADeclarationEntry().(VariableDeclarationEntry).getVariable() and
    definedVariable.getInitializer().getExpr() = baseVariableAccess and
    definedVariableType = definedVariable.getType() and
    not definedVariableType.getBaseType().isConst()
  )
}

/**
 * Holds if the variable behind a given variable access is taken its reference
 * as an argument of a call in either the body of the for-loop or in its update
 * expression.
 *
 * e.g.1. The loop counter variable `i` in the body is passed by reference to the
 * call to `f1`.
 * ``` C++
 * void f1(int &x);
 *
 * for (int i = j; i < k; i += l) {
 *   f1(i);
 * }
 * ```
 * e.g.2. The loop bound variable `k` in the body is passed by reference to the
 * call to `f1`.
 * ``` C++
 * void f1(int &x);
 *
 * for (int i = j; i < k; i += l) {
 *   f1(k);
 * }
 * ```
 */
private predicate variableReferenceTakenAsNonConstArgument(
  ForStmt forLoop, VariableAccess baseVariableAccess, Call call
) {
  exists(int index |
    call.getParent+() = forLoop.getAChild+() and
    call.getArgument(index).getAChild*() = baseVariableAccess.getTarget().getAnAccess() and
    /*
     * The given function has as parameter a reference of a constant
     * value, at a given index.
     */

    exists(ReferenceType parameterType |
      parameterType = call.getTarget().getParameter(index).getType() and
      not parameterType.getBaseType().isConst()
    ) and
    baseVariableAccess.getParent+() = forLoop
  )
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
  exists(VariableAccess loopCounterAccessInCondition |
    loopCounterAccessInCondition = forLoop.getCondition().(LegacyForLoopCondition).getLoopCounter()
  |
    exists(VariableAccess loopCounterAccessTakenAddressOrReference |
      loopCounterAccessInCondition.getTarget() =
        loopCounterAccessTakenAddressOrReference.getTarget()
    |
      variableAddressTakenInNonConstDeclaration(forLoop, loopCounterAccessTakenAddressOrReference)
      or
      variableAddressTakenInExpression(forLoop, loopCounterAccessTakenAddressOrReference) and
      not variableAddressTakenAsConstArgument(forLoop,
        loopCounterAccessTakenAddressOrReference.getTarget().getAnAccess(), _)
      or
      variableReferenceTakenInNonConstDeclaration(forLoop, loopCounterAccessTakenAddressOrReference)
      or
      variableReferenceTakenAsNonConstArgument(forLoop,
        loopCounterAccessTakenAddressOrReference.getTarget().getAnAccess(), _)
    )
  )
  or
  /* 6-2. The loop bound is taken a mutable reference or its address to a mutable pointer. */
  exists(VariableAccess loopBoundAccessInCondition |
    loopBoundAccessInCondition = forLoop.getCondition().(LegacyForLoopCondition).getLoopBound()
  |
    exists(VariableAccess loopBoundAccessTakenAddressOrReference |
      loopBoundAccessInCondition.getTarget() = loopBoundAccessTakenAddressOrReference.getTarget()
    |
      variableAddressTakenInNonConstDeclaration(forLoop, loopBoundAccessTakenAddressOrReference)
      or
      variableAddressTakenInExpression(forLoop, loopBoundAccessTakenAddressOrReference) and
      not variableAddressTakenAsConstArgument(forLoop,
        loopBoundAccessTakenAddressOrReference.getTarget().getAnAccess(), _)
      or
      variableReferenceTakenInNonConstDeclaration(forLoop, loopBoundAccessTakenAddressOrReference)
      or
      variableReferenceTakenAsNonConstArgument(forLoop, loopBoundAccessTakenAddressOrReference, _)
    )
  )
  or
  /* 6-3. The loop step is taken a mutable reference or its address to a mutable pointer. */
  exists(VariableAccess loopStepAccessInCondition |
    loopStepAccessInCondition = getLoopStepOfForStmt(forLoop)
  |
    exists(VariableAccess loopStepAccessTakenAddressOrReference |
      loopStepAccessInCondition.getTarget() = loopStepAccessTakenAddressOrReference.getTarget()
    |
      variableAddressTakenInNonConstDeclaration(forLoop, loopStepAccessTakenAddressOrReference)
      or
      variableAddressTakenInExpression(forLoop, loopStepAccessTakenAddressOrReference) and
      not variableAddressTakenAsConstArgument(forLoop,
        loopStepAccessTakenAddressOrReference.getTarget().getAnAccess(), _)
      or
      variableReferenceTakenInNonConstDeclaration(forLoop, loopStepAccessTakenAddressOrReference)
      or
      variableReferenceTakenAsNonConstArgument(forLoop,
        loopStepAccessTakenAddressOrReference.getTarget().getAnAccess(), _)
    )
  )
select forLoop, "TODO"

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
import codingstandards.cpp.Call
import codingstandards.cpp.misra.BuiltInTypeRules::MisraCpp23BuiltInTypes

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
    expr.getAChild*() = varAccess and // TODO: the `l` in the `i += l` is not mutated!
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

predicate loopVariableAssignedToPointerOrReferenceType(
  ForStmt forLoop, VariableAccess loopVariableAccessInCondition
) {
  exists(Expr assignmentRhs, DerivedType targetType |
    assignmentRhs.getEnclosingStmt().getParent*() = forLoop.getStmt() and
    (
      assignmentRhs.(AddressOfExpr).getOperand() =
        loopVariableAccessInCondition.getTarget().getAnAccess() or
      assignmentRhs = loopVariableAccessInCondition.getTarget().getAnAccess()
    ) and
    isAssignment(assignmentRhs, targetType, _) and
    (
      targetType instanceof PointerType or
      targetType instanceof ReferenceType
    ) and
    not targetType.getBaseType().isConst()
  )
}

/*
 * An adapted part of `BuiltinTypeRules::MisraCpp23BuiltInTypes::isPreConversionAssignment`
 * that is only relevant to an argument passed to a parameter, seen as an assignment.
 *
 * This predicate adds two constraints to the target type, as compared to the original
 * portion of the predicate:
 *
 * 1. This predicate adds type constraint that the target type is a `ReferenceType`.
 * 2. This predicate adds the constraint that the target type is not `const`.
 *
 * Also, this predicate requires that the call is the body of the given for-loop.
 */

predicate loopVariablePassedAsArgumentToReferenceParameter(
  ForStmt forLoop, Expr loopVariableAccessInCondition
) {
  exists(ReferenceType targetType |
    exists(Call call, int i |
      call.getArgument(i) = loopVariableAccessInCondition and
      call.getEnclosingStmt().getParent*() = forLoop.getStmt() and
      not targetType.getBaseType().isConst()
    |
      /* A regular function call */
      targetType = call.getTarget().getParameter(i).getType()
      or
      /* A function call where the argument is passed as varargs */
      call.getTarget().getNumberOfParameters() <= i and
      /* The rule states that the type should match the "adjusted" type of the argument */
      targetType = loopVariableAccessInCondition.getFullyConverted().getType()
      or
      /* An expression call - get the function type, then the parameter type */
      targetType = getExprCallFunctionType(call).getParameterType(i)
    )
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

  exists(VariableAccess loopVariableAccessInCondition |
    loopVariableAccessInCondition = forLoop.getCondition().(LegacyForLoopCondition).getLoopCounter() or
    loopVariableAccessInCondition = forLoop.getCondition().(LegacyForLoopCondition).getLoopBound() or
    loopVariableAccessInCondition = getLoopStepOfForStmt(forLoop)
  |
    loopVariableAssignedToPointerOrReferenceType(forLoop, loopVariableAccessInCondition)
    or
    loopVariablePassedAsArgumentToReferenceParameter(forLoop, loopVariableAccessInCondition)
  )
select forLoop, "TODO"

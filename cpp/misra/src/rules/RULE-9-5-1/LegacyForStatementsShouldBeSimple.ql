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
import semmle.code.cpp.dataflow.internal.AddressFlow
import codingstandards.cpp.misra
import codingstandards.cpp.Call
import codingstandards.cpp.Loops
import codingstandards.cpp.ast.Increment
import codingstandards.cpp.misra.BuiltInTypeRules::MisraCpp23BuiltInTypes

Variable getDeclaredVariableInForLoop(ForStmt forLoop) {
  result = forLoop.getADeclaration().getADeclarationEntry().(VariableDeclarationEntry).getVariable()
}

/**
 * Holds if the given expression may mutate the variable.
 */
predicate variableModifiedInExpression(Expr expr, VariableAccess va) {
  /*
   * 1. Direct modification (assignment, increment, etc.) or a function call.
   */

  expr.getAChild+() = va and
  va.isModified()
  or
  /*
   * 2. Address taken for non-const access that can potentially lead to modification.
   * This overlaps with the former example on cases where `expr` is a function call.
   */

  valueToUpdate(va, _, expr)
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
  /*
   * NOTE: We compute the transitive closure of `getAChild` on the update expression,
   * since the update expression may be a compound one that embeds the four aforementioned
   * expression types, such as a comma expression (e.g. `i += 1, E` where `E` is an
   * arbitrary expression).
   *
   * This may be detrimental to performance, but we keep it for soundness. A possible
   * alternative is an IR-based solution.
   */

  /* 1. Get the expression `E` when the update expression is `i += E` or `i -= E`. */
  result = forLoop.getUpdate().getAChild*().(StepCrementUpdateExpr).getAmountExpr()
}

/**
 * Holds if either of the following holds for the given variable access:
 * 1. Another variable access of the same variable as the given variable access is taken an
 * address and is assigned to a non-const pointer variable, i.e. initialization, assignment,
 * and pass-by-value.
 * 2. Another variable access of the same variable as the given variable access is assigned
 * to a non-const reference variable (thus constituting a `T` -> `&T` conversion.), i.e.
 * initialization and assignment.
 *
 * Note that pass-by-reference is dealt with in a different predicate named
 * `loopVariablePassedAsArgumentToNonConstReferenceParameter`, due to implementation
 * limitations.
 */
predicate loopVariableAssignedToNonConstPointerOrReferenceType(
  ForStmt forLoop, VariableAccess loopVariableAccessInCondition, Expr assignmentRhs
) {
  exists(Type targetType, DerivedType strippedType |
    isAssignment(assignmentRhs, targetType, _) and
    strippedType = targetType.stripTopLevelSpecifiers() and
    not strippedType.getBaseType().isConst() and
    (
      strippedType instanceof PointerType or
      strippedType instanceof ReferenceType
    )
  |
    assignmentRhs.getEnclosingStmt().getParent*() = forLoop.getStmt() and
    (
      /* 1. The address is taken: A loop variable access */
      assignmentRhs.(AddressOfExpr).getOperand() =
        loopVariableAccessInCondition.getTarget().getAnAccess()
      or
      /* 2. A reference is taken: A loop variable access */
      assignmentRhs = loopVariableAccessInCondition.getTarget().getAnAccess()
    )
  )
}

/**
 * Holds if the given variable access has another variable access with the same target
 * variable that is passed as reference to a non-const reference parameter of a function,
 * constituting a `T` -> `&T` conversion.
 *
 * This is an adapted part of
 * `BuiltinTypeRules::MisraCpp23BuiltInTypes::isPreConversionAssignment` that is only
 * relevant to an argument passed to a parameter, seen as an assignment.
 *
 * This predicate adds two constraints to the target type, as compared to the original
 * portion of the predicate:
 *
 * 1. This predicate adds a type constraint that the target type is a `ReferenceType`.
 * 2. This predicate adds the constraint that the target type is not `const`.
 *
 * Also, this predicate requires that the call is the body of the given for-loop.
 */
predicate loopVariablePassedAsArgumentToNonConstReferenceParameter(
  ForStmt forLoop, VariableAccess loopVariableAccessInCondition, Expr loopVariableArgument
) {
  exists(Type targetType, ReferenceType strippedReferenceType |
    exists(Call call, int i |
      loopVariableArgument = call.getArgument(i) and
      loopVariableArgument = loopVariableAccessInCondition.getTarget().getAnAccess() and
      call.getEnclosingStmt().getParent*() = forLoop.getStmt() and
      strippedReferenceType = targetType.stripTopLevelSpecifiers() and
      not strippedReferenceType.getBaseType().isConst()
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

private newtype TAlertType =
  /* 1. There is a counter variable that is not of an integer type. */
  TNonIntegerTypeCounterVariable(ForStmt forLoop, Variable loopCounter) {
    loopCounter = getDeclaredVariableInForLoop(forLoop) and
    exists(Type type | type = loopCounter.getType() |
      not (
        type instanceof IntegralType or
        type instanceof FixedWidthIntegralType
      )
    )
  } or
  /*
   * 2. The loop condition checks termination without comparing the counter variable to the
   * loop bound using a relational operator.
   */

  TNoRelationalOperatorInLoopCondition(ForStmt forLoop, Expr condition) {
    condition = forLoop.getCondition() and
    not condition instanceof LegacyForLoopCondition
  } or
  /* 3-1. The loop counter is mutated somewhere other than its update expression. */
  TLoopCounterMutatedInLoopBody(ForStmt forLoop, Variable loopCounterVariable, Expr mutatingExpr) {
    loopCounterVariable = getDeclaredVariableInForLoop(forLoop) and
    not mutatingExpr = forLoop.getUpdate().getAChild*() and
    variableModifiedInExpression(mutatingExpr, loopCounterVariable.getAnAccess())
  } or
  /* 3-2. The loop counter is not updated using either of `++`, `--`, `+=`, or `-=`. */
  TLoopCounterUpdatedNotByCrementOrAddSubAssignmentExpr(
    ForStmt forLoop, Variable loopCounterVariable, Expr updateExpr
  ) {
    loopCounterVariable = getDeclaredVariableInForLoop(forLoop) and
    updateExpr = forLoop.getUpdate() and
    variableModifiedInExpression(updateExpr, loopCounterVariable.getAnAccess()) and
    not updateExpr instanceof StepCrementUpdateExpr
  } or
  /* 4. The type size of the loop counter is smaller than that of the loop bound. */
  TLoopCounterSmallerThanLoopBound(ForStmt forLoop, LegacyForLoopCondition forLoopCondition) {
    forLoopCondition = forLoop.getCondition() and
    exists(Expr loopCounter, Expr loopBound |
      loopCounter = forLoopCondition.getLoopCounter() and
      loopBound = forLoopCondition.getLoopBound()
    |
      typeUpperBound(loopCounter.getType()) < upperBound(loopBound.getFullyConverted())
    )
  } or
  /* 5-1-1. The loop bound is a variable that is mutated in the for loop. */
  TLoopBoundIsMutatedVariableAccess(
    ForStmt forLoop, VariableAccess variableAccess, VariableAccess mutatedVariableAccess
  ) {
    exists(Expr loopBoundExpr, Expr mutatingExpr |
      loopBoundExpr = forLoop.getCondition().(LegacyForLoopCondition).getLoopBound() and
      (
        /* 1. The mutating expression may be in the loop body. */
        mutatingExpr = forLoop.getStmt().getChildStmt().getAChild*()
        or
        /* 2. The mutating expression may be in the loop updating expression. */
        mutatingExpr = forLoop.getUpdate().getAChild*()
        or
        /* 3. The mutating expression may be in the loop condition */
        mutatingExpr = forLoop.getCondition().getAChild*()
        or
        /* 4. The mutating expression may be in the loop initializer */
        mutatingExpr = forLoop.getInitialization().getAChild*()
      ) and
      variableAccess = loopBoundExpr.getAChild*() and
      mutatedVariableAccess = variableAccess.getTarget().getAnAccess() and
      variableModifiedInExpression(mutatingExpr, mutatedVariableAccess)
    )
  } or
  /* 5-1-2. The loop bound is not a variable access nor a constant expression. */
  TLoopBoundIsNonConstExpr(ForStmt forLoop, Expr loopBound) {
    loopBound = forLoop.getCondition().(LegacyForLoopCondition).getLoopBound() and
    (not loopBound instanceof VariableAccess and not loopBound.isConstant())
  } or
  /* 5-2-1. The loop step is a variable that is mutated in the for loop. */
  TLoopStepIsMutatedVariableAccess(
    ForStmt forLoop, VariableAccess variableAccess, VariableAccess mutatedVariableAccess
  ) {
    exists(Expr loopStepExpr, Expr mutatingExpr |
      loopStepExpr = getLoopStepOfForStmt(forLoop) and
      (
        /* 1. The mutating expression may be in the loop body. */
        mutatingExpr = forLoop.getStmt().getChildStmt().getAChild*()
        or
        /* 2. The mutating expression may be in the loop updating expression. */
        mutatingExpr = forLoop.getUpdate().getAChild*()
        or
        /* 3. The mutating expression may be in the loop condition */
        mutatingExpr = forLoop.getCondition().getAChild*()
        or
        /* 4. The mutating expression may be in the loop initializer */
        mutatingExpr = forLoop.getInitialization().getAChild*()
      ) and
      variableAccess = loopStepExpr.getAChild*() and
      mutatedVariableAccess = variableAccess.getTarget().getAnAccess() and
      variableModifiedInExpression(mutatingExpr, mutatedVariableAccess)
    )
  } or
  /* 5-2-2. The loop step is not a variable access nor a constant expression. */
  TLoopStepIsNonConstExpr(ForStmt forLoop, Expr loopStep) {
    loopStep = getLoopStepOfForStmt(forLoop) and
    (not loopStep instanceof VariableAccess and not loopStep.isConstant())
  } or
  /*
   * 6-1. The loop counter is taken as a mutable reference or its address to a mutable pointer.
   */

  TLoopCounterIsTakenNonConstAddress(
    ForStmt forLoop, VariableAccess loopVariableAccessInCondition,
    Expr loopVariableAccessInAssignment
  ) {
    loopVariableAccessInCondition = forLoop.getCondition().(LegacyForLoopCondition).getLoopCounter() and
    (
      loopVariableAssignedToNonConstPointerOrReferenceType(forLoop, loopVariableAccessInCondition,
        loopVariableAccessInAssignment)
      or
      loopVariablePassedAsArgumentToNonConstReferenceParameter(forLoop,
        loopVariableAccessInCondition, loopVariableAccessInAssignment)
    )
  } or
  /*
   * 6-2. The loop bound is taken as a mutable reference or its address to a mutable pointer.
   */

  TLoopBoundIsTakenNonConstAddress(
    ForStmt forLoop, Expr loopBoundExpr, Expr loopVariableAccessInAssignment
  ) {
    loopBoundExpr = forLoop.getCondition().(LegacyForLoopCondition).getLoopBound() and
    exists(VariableAccess variableAccess |
      variableAccess = loopBoundExpr.getAChild*() and
      (
        loopVariableAssignedToNonConstPointerOrReferenceType(forLoop, variableAccess,
          loopVariableAccessInAssignment)
        or
        loopVariablePassedAsArgumentToNonConstReferenceParameter(forLoop, variableAccess,
          loopVariableAccessInAssignment)
      )
    )
  } or
  /*
   * 6-3. The loop step is taken as a mutable reference or its address to a mutable pointer.
   */

  TLoopStepIsTakenNonConstAddress(
    ForStmt forLoop, Expr loopVariableAccessInCondition, Expr loopVariableAccessInAssignment
  ) {
    loopVariableAccessInCondition = getLoopStepOfForStmt(forLoop) and
    (
      loopVariableAssignedToNonConstPointerOrReferenceType(forLoop, loopVariableAccessInCondition,
        loopVariableAccessInAssignment)
      or
      loopVariablePassedAsArgumentToNonConstReferenceParameter(forLoop,
        loopVariableAccessInCondition, loopVariableAccessInAssignment)
    )
  }

class AlertType extends TAlertType {
  /**
   * Extract the primary location depending on the case of this instance.
   */
  Location getLocation() { result = this.asElement().getLocation() }

  Element asElement() {
    this = TNonIntegerTypeCounterVariable(result, _) or
    this = TNoRelationalOperatorInLoopCondition(result, _) or
    this = TLoopCounterMutatedInLoopBody(result, _, _) or
    this = TLoopCounterUpdatedNotByCrementOrAddSubAssignmentExpr(result, _, _) or
    this = TLoopCounterSmallerThanLoopBound(result, _) or
    this = TLoopBoundIsMutatedVariableAccess(result, _, _) or
    this = TLoopBoundIsNonConstExpr(result, _) or
    this = TLoopStepIsMutatedVariableAccess(result, _, _) or
    this = TLoopStepIsNonConstExpr(result, _) or
    this = TLoopCounterIsTakenNonConstAddress(result, _, _) or
    this = TLoopBoundIsTakenNonConstAddress(result, _, _) or
    this = TLoopStepIsTakenNonConstAddress(result, _, _)
  }

  /**
   * Gets the target the link leads to depending on the case of this instance.
   */
  Locatable getLinkTarget1() {
    this = TNonIntegerTypeCounterVariable(_, result)
    or
    this = TNoRelationalOperatorInLoopCondition(_, result)
    or
    this = TLoopCounterMutatedInLoopBody(_, result, _)
    or
    this = TLoopCounterUpdatedNotByCrementOrAddSubAssignmentExpr(_, result, _)
    or
    exists(LegacyForLoopCondition forLoopCondition |
      this = TLoopCounterSmallerThanLoopBound(_, forLoopCondition) and
      result = forLoopCondition.getLoopCounter()
    )
    or
    this = TLoopBoundIsNonConstExpr(_, result)
    or
    this = TLoopBoundIsMutatedVariableAccess(_, result, _)
    or
    this = TLoopStepIsNonConstExpr(_, result)
    or
    this = TLoopStepIsMutatedVariableAccess(_, result, _)
    or
    this = TLoopCounterIsTakenNonConstAddress(_, result, _)
    or
    this = TLoopBoundIsTakenNonConstAddress(_, result, _)
    or
    this = TLoopStepIsTakenNonConstAddress(_, result, _)
  }

  /**
   * Gets the text of the link depending on the case of this instance.
   */
  string getLinkText1() {
    this = TNonIntegerTypeCounterVariable(_, _) and
    result = "counter variable"
    or
    this = TNoRelationalOperatorInLoopCondition(_, _) and
    result = "loop condition"
    or
    this = TLoopCounterMutatedInLoopBody(_, _, _) and
    result = "counter variable"
    or
    this = TLoopCounterUpdatedNotByCrementOrAddSubAssignmentExpr(_, _, _) and
    result = "counter variable"
    or
    this = TLoopCounterSmallerThanLoopBound(_, _) and
    result = "counter variable"
    or
    this = TLoopBoundIsMutatedVariableAccess(_, _, _) and
    result = "loop bound"
    or
    this = TLoopBoundIsNonConstExpr(_, _) and
    result = "loop bound"
    or
    this = TLoopStepIsMutatedVariableAccess(_, _, _) and
    result = "loop step"
    or
    this = TLoopStepIsNonConstExpr(_, _) and
    result = "loop step"
    or
    this = TLoopCounterIsTakenNonConstAddress(_, _, _) and
    result = "loop counter"
    or
    this = TLoopBoundIsTakenNonConstAddress(_, _, _) and
    result = "loop bound"
    or
    this = TLoopStepIsTakenNonConstAddress(_, _, _) and
    result = "loop step"
  }

  /**
   * Gets the message with a placeholder, depending on the case of this instance.
   */
  string getMessage() {
    this = TNonIntegerTypeCounterVariable(_, _) and
    result = "The $@ is not of an integer type."
    or
    this = TNoRelationalOperatorInLoopCondition(_, _) and
    result =
      "The $@ does not determine termination based only on a comparison against the value of the counter variable."
    or
    this = TLoopCounterMutatedInLoopBody(_, _, _) and
    result = "The $@ may be mutated in $@ other than its update expression."
    or
    this = TLoopCounterUpdatedNotByCrementOrAddSubAssignmentExpr(_, _, _) and
    result = "The $@ is not updated with an $@ other than addition or subtraction."
    or
    this = TLoopCounterSmallerThanLoopBound(_, _) and
    result = "The $@ has a smaller type than that of the $@."
    or
    this = TLoopBoundIsNonConstExpr(_, _) and
    result = "The $@ is a $@."
    or
    this = TLoopBoundIsMutatedVariableAccess(_, _, _) and
    result = "The $@ is a non-const expression, or a variable that may be $@ in the loop."
    or
    this = TLoopStepIsNonConstExpr(_, _) and
    result = "The $@ is a $@."
    or
    this = TLoopStepIsMutatedVariableAccess(_, _, _) and
    result = "The $@ is a non-const expression, or a variable that may be $@ in the loop."
    or
    this = TLoopCounterIsTakenNonConstAddress(_, _, _) and
    result = "The $@ is $@."
    or
    this = TLoopBoundIsTakenNonConstAddress(_, _, _) and
    result = "The $@ is $@."
    or
    this = TLoopStepIsTakenNonConstAddress(_, _, _) and
    result = "The $@ is $@."
  }

  Locatable getLinkTarget2() {
    this = TNonIntegerTypeCounterVariable(_, result) // Throwaway
    or
    this = TNoRelationalOperatorInLoopCondition(_, result) // Throwaway
    or
    this = TLoopCounterMutatedInLoopBody(_, _, result)
    or
    this = TLoopCounterUpdatedNotByCrementOrAddSubAssignmentExpr(_, _, result)
    or
    exists(LegacyForLoopCondition forLoopCondition |
      this = TLoopCounterSmallerThanLoopBound(_, forLoopCondition) and
      result = forLoopCondition.getLoopBound()
    )
    or
    this = TLoopBoundIsNonConstExpr(_, result)
    or
    this = TLoopBoundIsMutatedVariableAccess(_, _, result)
    or
    this = TLoopStepIsNonConstExpr(_, result)
    or
    this = TLoopStepIsMutatedVariableAccess(_, _, result)
    or
    this = TLoopCounterIsTakenNonConstAddress(_, _, result)
    or
    this = TLoopBoundIsTakenNonConstAddress(_, _, result)
    or
    this = TLoopStepIsTakenNonConstAddress(_, _, result)
  }

  string getLinkText2() {
    this = TNonIntegerTypeCounterVariable(_, _) and
    result = "N/A" // Throwaway
    or
    this = TNoRelationalOperatorInLoopCondition(_, _) and
    result = "N/A" // Throwaway
    or
    this = TLoopCounterMutatedInLoopBody(_, _, _) and
    result = "a location"
    or
    this = TLoopCounterUpdatedNotByCrementOrAddSubAssignmentExpr(_, _, _) and
    result = "expression"
    or
    this = TLoopCounterSmallerThanLoopBound(_, _) and
    result = "loop bound"
    or
    this = TLoopBoundIsNonConstExpr(_, _) and
    result = "non-const expression"
    or
    this = TLoopBoundIsMutatedVariableAccess(_, _, _) and
    result = "mutated"
    or
    this = TLoopStepIsNonConstExpr(_, _) and
    result = "non-const expression"
    or
    this = TLoopStepIsMutatedVariableAccess(_, _, _) and
    result = "mutated"
    or
    this = TLoopCounterIsTakenNonConstAddress(_, _, _) and
    result = "taken as a mutable reference or its address to a mutable pointer"
    or
    this = TLoopBoundIsTakenNonConstAddress(_, _, _) and
    result = "taken as a mutable reference or its address to a mutable pointer"
    or
    this = TLoopStepIsTakenNonConstAddress(_, _, _) and
    result = "taken as a mutable reference or its address to a mutable pointer"
  }

  string toString() { result = this.asElement().toString() }
}

from AlertType alert
where not isExcluded(alert.asElement(), StatementsPackage::legacyForStatementsShouldBeSimpleQuery())
select alert, alert.getMessage(), alert.getLinkTarget1(), alert.getLinkText1(),
  alert.getLinkTarget2(), alert.getLinkText2()

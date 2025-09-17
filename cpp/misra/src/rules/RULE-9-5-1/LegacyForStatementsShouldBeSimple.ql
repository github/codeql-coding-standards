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
    loopCounter.getTarget() = getAnIterationVariable(forLoop) and
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
  result = forLoop.getUpdate().(AssignAddExpr).getRValue() or
  result = forLoop.getUpdate().(AssignSubExpr).getRValue()
}

/**
 * Holds if either of the following holds for the given variable access:
 * 1. Another variable access of the same variable as the given variable access is taken an
 * address and is assigned to a non-const pointer variable, i.e. initialization, assignment,
 * and pass-by-value.
 * 2. Another variable access of the same variable as the given variable access is assigned
 * to a non-const reference variable (thus constituting a `T` -> `&T` conversion.), i.e.
 * initialization and assignment.
 */
/*
 * Note that pass-by-reference is dealt with in a different predicate named
 * `loopVariablePassedAsArgumentToNonConstReferenceParameter`, due to implementation
 * limitations.
 */

predicate loopVariableAssignedToNonConstPointerOrReferenceType(
  ForStmt forLoop, VariableAccess loopVariableAccessInCondition
) {
  exists(Expr assignmentRhs, DerivedType targetType |
    isAssignment(assignmentRhs, targetType, _) and
    not targetType.getBaseType().isConst() and
    (
      targetType instanceof PointerType or
      targetType instanceof ReferenceType
    )
  |
    assignmentRhs.getEnclosingStmt().getParent*() = forLoop.getStmt() and
    (
      /* 1. The address is taken: A loop variable access */
      assignmentRhs.(AddressOfExpr).getOperand() =
        loopVariableAccessInCondition.getTarget().getAnAccess()
      or
      /* 2. The address is taken: A loop variable access */
      assignmentRhs = loopVariableAccessInCondition.getTarget().getAnAccess()
    )
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

/**
 * Holds if the given variable access has another variable access with the same target
 * variable that is passed as reference to a non-const reference parameter of a function,
 * constituting a `T` -> `&T` conversion.
 */
predicate loopVariablePassedAsArgumentToNonConstReferenceParameter(
  ForStmt forLoop, VariableAccess loopVariableAccessInCondition
) {
  exists(ReferenceType targetType |
    exists(Call call, int i |
      call.getArgument(i) = loopVariableAccessInCondition.getTarget().getAnAccess() and
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
  exists(Variable loopCounter |
    isIrregularLoopCounterModification(forLoop, loopCounter, loopCounter.getAnAccess())
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
  /*
   * 5. The loop bound and the loop step are non-const expressions, or are variables that are
   * mutated in the for loop.
   */

  /* 5-1. The mutating expression mutates the loop bound. */
  exists(Expr loopBound |
    loopBound = forLoop.getCondition().(LegacyForLoopCondition).getLoopBound()
  |
    exists(Expr mutatingExpr |
      /* The mutating expression may be in the loop body. */
      mutatingExpr = forLoop.getStmt().getChildStmt().getAChild*()
      or
      /* The mutating expression may be in the loop updating expression. */
      mutatingExpr = forLoop.getUpdate().getAChild*()
    |
      /* 5-1-1. The loop bound is a variable that is mutated in the for loop. */
      variableModifiedInExpression(mutatingExpr,
        loopBound.(VariableAccess).getTarget().getAnAccess())
      or
      /* 5-1-2. The loop bound is not a variable access and is not a constant expression. */
      not loopBound instanceof VariableAccess and not loopBound.isConstant()
    )
  )
  or
  /* 5-2. The mutating expression mutates the loop step. */
  exists(Expr loopStep | loopStep = getLoopStepOfForStmt(forLoop) |
    exists(Expr mutatingExpr |
      /* The mutating expression may be in the loop body. */
      mutatingExpr = forLoop.getStmt().getChildStmt().getAChild*()
      or
      /* The mutating expression may be in the loop updating expression. */
      mutatingExpr = forLoop.getUpdate().getAChild*()
    |
      /* 5-1-2. The loop step is a variable that is mutated in the for loop. */
      variableModifiedInExpression(mutatingExpr, loopStep.(VariableAccess).getTarget().getAnAccess())
      or
      /* 5-1-2. The loop bound is not a variable access and is not a constant expression. */
      not loopStep instanceof VariableAccess and not loopStep.isConstant()
    )
  )
  or
  /*
   * 6. Any of the loop counter, loop bound, or a loop step is taken as a mutable reference
   * or its address to a mutable pointer.
   */

  exists(VariableAccess loopVariableAccessInCondition |
    (
      loopVariableAccessInCondition =
        forLoop.getCondition().(LegacyForLoopCondition).getLoopCounter() or
      loopVariableAccessInCondition = forLoop.getCondition().(LegacyForLoopCondition).getLoopBound() or
      loopVariableAccessInCondition = getLoopStepOfForStmt(forLoop)
    ) and
    (
      loopVariableAssignedToNonConstPointerOrReferenceType(forLoop, loopVariableAccessInCondition)
      or
      loopVariablePassedAsArgumentToNonConstReferenceParameter(forLoop,
        loopVariableAccessInCondition)
    )
  )
select forLoop, "TODO"

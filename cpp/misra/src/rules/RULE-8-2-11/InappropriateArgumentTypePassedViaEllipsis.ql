/**
 * @id cpp/misra/inappropriate-argument-type-passed-via-ellipsis
 * @name RULE-8-2-11: An argument passed via ellipsis shall have an appropriate type
 * @description Passing arguments of certain class types via an ellipsis parameter is only
 *              conditionally-supported with implementation-defined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-11
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.types.TrivialType

/**
 * Holds if `arg` is an argument passed via ellipsis in `call`.
 */
predicate isEllipsisArgument(FunctionCall call, Expr arg, int i) {
  call.getTarget().isVarargs() and
  arg = call.getArgument(i) and
  i >= call.getTarget().getNumberOfParameters()
}

/**
 * Holds if `c` has virtual member functions.
 */
predicate hasVirtualMemberFunctions(Class c) { c.getAMemberFunction().isVirtual() }

/**
 * Holds if `c` has non-trivial copy or move operations.
 */
predicate hasNonTrivialCopyOrMove(Class c) {
  exists(CopyConstructor cc | cc = c.getAConstructor() |
    not cc instanceof TrivialCopyOrMoveConstructor
  )
  or
  exists(MoveConstructor mc | mc = c.getAConstructor() |
    not mc instanceof TrivialCopyOrMoveConstructor
  )
  or
  exists(CopyAssignmentOperator ca | ca = c.getAMemberFunction() |
    not ca instanceof TrivialCopyOrMoveAssignmentOperator
  )
  or
  exists(MoveAssignmentOperator ma | ma = c.getAMemberFunction() |
    not ma instanceof TrivialCopyOrMoveAssignmentOperator
  )
}

/**
 * Holds if `c` has a non-trivial destructor.
 */
predicate hasNonTrivialDestructor(Class c) { not hasTrivialDestructor(c) }

/**
 * Gets the primary reason why `c` is an inappropriate type to pass via ellipsis, prioritized
 * by the order of conditions in the rule amplification.
 */
string getInappropriateReason(Class c) {
  if hasVirtualMemberFunctions(c)
  then result = "has virtual member functions"
  else
    if hasNonTrivialCopyOrMove(c)
    then result = "has non-trivial copy or move operations"
    else (
      hasNonTrivialDestructor(c) and result = "has a non-trivial destructor"
    )
}

from FunctionCall call, Expr arg, int i, Class argType, string reason
where
  not isExcluded(arg, Preconditions2Package::inappropriateArgumentTypePassedViaEllipsisQuery()) and
  isEllipsisArgument(call, arg, i) and
  // `arg.getType()` is void for some constructor calls. These seem to have a conversion of class
  // `TemporaryObjectExpr`, which seems to have the correct type.
  argType = arg.getFullyConverted().getUnspecifiedType() and
  reason = getInappropriateReason(argType) and
  // Exclude unevaluated contexts
  not arg.isUnevaluated() and
  not call.isUnevaluated()
select arg,
  "Argument of type '" + argType.getName() + "' passed via ellipsis to $@ " + reason + ".",
  call.getTarget(), call.getTarget().getName()

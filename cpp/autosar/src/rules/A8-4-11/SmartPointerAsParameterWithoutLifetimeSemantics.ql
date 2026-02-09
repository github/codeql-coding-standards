/**
 * @id cpp/autosar/smart-pointer-as-parameter-without-lifetime-semantics
 * @name A8-4-11: A smart pointer shall only be used as a parameter type if it expresses lifetime semantics
 * @description If a smart pointer object is passed into a function for uses which do not affect its
 *              lifetime, then a reference or raw pointer should be used instead.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a8-4-11
 *       maintainability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SmartPointers
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.standardlibrary.Utility

Expr lifetimeAffectingSmartPointerExpr(Function f) {
  result =
    any(VariableAccess va, FunctionCall fc |
      va.getEnclosingFunction() = f and
      // strip the type so as to include reference parameter types
      va.getType().stripType() instanceof AutosarSmartPointer and
      // any lifetime operation will involve an implicit or explicit function call
      // such as: move ctor, copy ctor, 'reset', 'swap', and 'release'
      // no such constructor call occurs with a reference or pointer-type argument passed
      (
        fc.getTarget().getDeclaringType().stripType() instanceof AutosarSmartPointer or
        fc.(StdMoveCall).getArgument(0).getType().stripType() instanceof AutosarSmartPointer or
        fc.(StdForwardCall).getArgument(0).getType().stripType() instanceof AutosarSmartPointer
      ) and
      fc = va.(VariableAccess).getParent() and
      // specifically exclude the only non-lifetime-affecting operators and methods
      not fc.getTarget().hasName(["operator->", "operator*", "get"])
    |
      va
    )
}

predicate flowsToLifetimeAffectingExpr(Parameter p) {
  // check if a parameter flows locally to an expression which affects smart pointer lifetime
  p.getType().stripType() instanceof AutosarSmartPointer and
  DataFlow::localExprFlow(p.getAnAccess(), lifetimeAffectingSmartPointerExpr(p.getFunction()))
  or
  // else handle nested cases, such as passing smart pointers as reference arguments
  exists(FunctionCall fc, VariableAccess va, int index |
    // calls to functions that are not methods of AutosarSmartPointer and which do not
    // result in a constructor call are excluded from 'flowsToLifetimeAffectingExpr'.
    // therefore, recurse through function calls where the parameter 'p' flows to an argument
    fc.getEnclosingFunction() = p.getFunction() and
    fc.getArgument(index) = va and
    DataFlow::localExprFlow(p.getAnAccess(), va) and
    flowsToLifetimeAffectingExpr(fc.getTarget().getParameter(index))
  )
}

from DefinedSmartPointerParameter p
where
  not isExcluded(p, SmartPointers1Package::smartPointerAsParameterWithoutLifetimeSemanticsQuery()) and
  not flowsToLifetimeAffectingExpr(p)
select p,
  "Function $@ takes smart pointer parameter '" + p.getName() +
    "' but does not implement any lifetime-affecting operations.", p.getFunction(),
  p.getFunction().getName()

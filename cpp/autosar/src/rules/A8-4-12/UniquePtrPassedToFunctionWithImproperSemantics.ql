/**
 * @id cpp/autosar/unique-ptr-passed-to-function-with-improper-semantics
 * @name A8-4-12: A std::unique_ptr shall be passed to a function as a copy if the function assumes ownership, or as an lvalue reference if the function replaces the managed object
 * @description A std::unique_ptr shall be passed to a function as: (1) a copy to express the
 *              function assumes ownership (2) an lvalue reference to express that the function
 *              replaces the managed object.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a8-4-12
 *       maintainability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SmartPointers
import codingstandards.cpp.standardlibrary.Utility
import semmle.code.cpp.dataflow.DataFlow

Expr underlyingObjectAffectingUniquePointerExpr(Function f) {
  result =
    any(VariableAccess va, FunctionCall fc |
      va.getEnclosingFunction() = f and
      // strip the type so as to include reference parameter types
      va.getType().stripType() instanceof AutosarUniquePointer and
      fc.getTarget().getDeclaringType().stripType() instanceof AutosarUniquePointer and
      fc.getQualifier() = va and
      // include only calls to methods which modify the underlying object
      fc.getTarget().hasName(["operator=", "reset", "release", "swap"])
    |
      va
    )
}

predicate flowsToUnderlyingObjectAffectingExpr(Parameter p) {
  // check if a parameter flows locally to an expression which affects smart pointer lifetime
  p.getType().stripType() instanceof AutosarSmartPointer and
  DataFlow::localExprFlow(p.getAnAccess(),
    underlyingObjectAffectingUniquePointerExpr(p.getFunction()))
  or
  // else handle nested cases, such as passing smart pointers as reference arguments
  exists(FunctionCall fc, VariableAccess va, int index |
    // calls to functions that are not methods of AutosarSmartPointer and which do not
    // result in a constructor call are excluded from 'flowsToLifetimeAffectingExpr'.
    // therefore, recurse through function calls where the parameter 'p' flows to an argument
    fc.getEnclosingFunction() = p.getFunction() and
    fc.getArgument(index) = va and
    DataFlow::localExprFlow(p.getAnAccess(), va) and
    flowsToUnderlyingObjectAffectingExpr(fc.getTarget().getParameter(index))
  )
}

from DefinedSmartPointerParameter p, string problem
where
  not isExcluded(p, SmartPointers1Package::smartPointerAsParameterWithoutLifetimeSemanticsQuery()) and
  p.getType().stripType() instanceof AutosarUniquePointer and
  (
    // handle the parameter depending on its derived type
    p instanceof ConsumeParameter and
    not exists(StdMoveCall call | p.getAnAccess() = call.getAnArgument()) and
    problem =
      "Parameter of type std::unique_ptr passed as rvalue reference without subsequent move to object."
    or
    p.getType() instanceof LValueReferenceType and
    not flowsToUnderlyingObjectAffectingExpr(p) and
    problem =
      "Parameter of type std::unique_ptr passed as lvalue reference but not used to modify underlying object."
    or
    p.getType() instanceof PointerType and
    problem = "Parameter of type std::unique_ptr passed as raw pointer."
  )
select p, problem

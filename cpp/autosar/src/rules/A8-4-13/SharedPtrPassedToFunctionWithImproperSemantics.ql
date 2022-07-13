/**
 * @id cpp/autosar/shared-ptr-passed-to-function-with-improper-semantics
 * @name A8-4-13: A std::shared_ptr shall be passed to a function as a copy if the function shares ownership, as an lvalue reference if the function replaces the managed object, or as a const lvalue reference if the function retains a reference count
 * @description A std::shared_ptr shall be passed to a function as: (1) a copy to express the
 *              function shares ownership (2) an lvalue reference to express that the function
 *              replaces the managed object (3) a const lvalue reference to express that the
 *              function retains a reference count.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a8-4-13
 *       maintainability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SmartPointers

Expr underlyingObjectAffectingSharedPointerExpr(Function f) {
  result =
    any(VariableAccess va, FunctionCall fc |
      va.getEnclosingFunction() = f and
      // strip the type so as to include reference parameter types
      va.getType().stripType() instanceof AutosarSharedPointer and
      fc.getTarget().getDeclaringType().stripType() instanceof AutosarSharedPointer and
      fc.getQualifier() = va and
      // include only calls to methods which modify the underlying object
      fc.getTarget().hasName(["operator=", "reset", "swap"])
    |
      va
    )
}

predicate flowsToUnderlyingObjectAffectingExpr(Parameter p) {
  // check if a parameter flows locally to an expression which affects smart pointer lifetime
  p.getType().stripType() instanceof AutosarSharedPointer and
  localExprFlow(p.getAnAccess(), underlyingObjectAffectingSharedPointerExpr(p.getFunction()))
  or
  // else handle nested cases, such as passing smart pointers as reference arguments
  exists(FunctionCall fc, VariableAccess va, int index |
    // calls to functions that are not methods of AutosarSmartPointer and which do not
    // result in a constructor call are excluded from 'flowsToLifetimeAffectingExpr'.
    // therefore, recurse through function calls where the parameter 'p' flows to an argument
    fc.getEnclosingFunction() = p.getFunction() and
    fc.getArgument(index) = va and
    localExprFlow(p.getAnAccess(), va) and
    flowsToUnderlyingObjectAffectingExpr(fc.getTarget().getParameter(index))
  )
}

from DefinedSmartPointerParameter p, string problem
where
  not isExcluded(p, SmartPointers1Package::smartPointerAsParameterWithoutLifetimeSemanticsQuery()) and
  p.getType().stripType() instanceof AutosarSharedPointer and
  (
    // handle the parameter depending on its derived type
    p.getType() instanceof RValueReferenceType and
    problem = "Parameter of type std::shared_ptr passed as rvalue reference."
    or
    p.getType() instanceof LValueReferenceType and
    (
      p.getType().(LValueReferenceType).getBaseType().isConst() and
      not localExprFlow(p.getAnAccess(),
        any(Variable var, ConstructorCall cc |
          var.getType() instanceof AutosarSharedPointer and
          var.getAnAssignedValue() = cc and
          cc.getTarget() instanceof CopyConstructor
        |
          cc.getArgument(0)
        )) and
      problem =
        "Parameter of type 'const std::shared_ptr' passed as lvalue reference with no copy made."
      or
      not p.getType().(LValueReferenceType).getBaseType().isConst() and
      not flowsToUnderlyingObjectAffectingExpr(p) and
      problem =
        "Parameter of type std::shared_ptr passed as lvalue reference but not used to modify underlying object."
    )
    or
    p.getType() instanceof PointerType and
    problem = "Parameter of type std::shared_ptr passed as raw pointer."
  )
select p, problem

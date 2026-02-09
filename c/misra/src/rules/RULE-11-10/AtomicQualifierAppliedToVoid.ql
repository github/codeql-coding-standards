/**
 * @id c/misra/atomic-qualifier-applied-to-void
 * @name RULE-11-10: The _Atomic qualifier shall not be applied to the incomplete type void
 * @description Conversions between types by using an _Atomic void type may result in undefined
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-10
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

class AtomicVoidType extends Type {
  AtomicVoidType() {
    hasSpecifier("atomic") and
    getUnspecifiedType() instanceof VoidType
  }
}

predicate usesAtomicVoid(Type root) {
  root instanceof AtomicVoidType
  or
  usesAtomicVoid(root.(DerivedType).getBaseType())
  or
  usesAtomicVoid(root.(RoutineType).getReturnType())
  or
  usesAtomicVoid(root.(RoutineType).getAParameterType())
  or
  usesAtomicVoid(root.(FunctionPointerType).getReturnType())
  or
  usesAtomicVoid(root.(FunctionPointerType).getAParameterType())
  or
  usesAtomicVoid(root.(TypedefType).getBaseType())
}

class ExplicitType extends Type {
  Element getDeclaration(string description) {
    result.(DeclarationEntry).getType() = this and description = result.(DeclarationEntry).getName()
    or
    result.(CStyleCast).getType() = this and description = "Cast"
  }
}

from Element decl, ExplicitType explicitType, string elementDescription
where
  not isExcluded(decl, Declarations9Package::atomicQualifierAppliedToVoidQuery()) and
  decl = explicitType.getDeclaration(elementDescription) and
  usesAtomicVoid(explicitType)
select decl, elementDescription + " declared with an atomic void type."

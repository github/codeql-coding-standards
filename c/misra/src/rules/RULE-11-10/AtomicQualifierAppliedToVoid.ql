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

Type getNestedType(Type root) {
  result = root
  or
  exists(DerivedType derived | derived = root | result = getNestedType(derived.getBaseType()))
}

from DeclarationEntry decl, AtomicVoidType atomicVoid
where
  not isExcluded(decl, Declarations9Package::atomicQualifierAppliedToVoidQuery()) and
  atomicVoid = getNestedType(decl.getType())
select decl, decl.getName() + " declared with an atomic void type."

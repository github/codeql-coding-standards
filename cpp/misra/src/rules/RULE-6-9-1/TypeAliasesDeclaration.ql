/**
 * @id cpp/misra/type-aliases-declaration
 * @name RULE-6-9-1: The same type aliases shall be used in all declarations of the same entity
 * @description Using different type aliases on redeclarations can make code hard to understand and
 *              maintain.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-6-9-1
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from DeclarationEntry decl1, DeclarationEntry decl2, TypedefType t
where
  not isExcluded(decl1, Declarations5Package::typeAliasesDeclarationQuery()) and
  not isExcluded(decl2, Declarations5Package::typeAliasesDeclarationQuery()) and
  not decl1 = decl2 and
  decl1.getDeclaration() = decl2.getDeclaration() and
  t.getATypeNameUse() = decl1 and
  not t.getATypeNameUse() = decl2 and
  //exception cases - we dont want to disallow struct typedef name use
  not t.getBaseType() instanceof Struct and
  not t.getBaseType() instanceof Enum
select decl1,
  "Declaration entry has a different type alias than $@ where the type alias used is '$@'.", decl2,
  decl2.getName(), t, t.getName()

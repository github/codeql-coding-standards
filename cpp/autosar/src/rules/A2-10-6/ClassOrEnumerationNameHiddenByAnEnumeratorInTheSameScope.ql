/**
 * @id cpp/autosar/class-or-enumeration-name-hidden-by-an-enumerator-in-the-same-scope
 * @name A2-10-6: Hiding of class or enumeration name by an enumerator declaration in the same scope
 * @description A class or enumeration name shall not be hidden by an enumerator declaration in the
 *              same scope.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a2-10-6
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Scope
import ClassOrEnum

from ClassOrEnum t, EnumConstant c
where
  not isExcluded(t, NamingPackage::classOrEnumerationNameHiddenByAFunctionInTheSameScopeQuery()) and
  not isExcluded(c, NamingPackage::classOrEnumerationNameHiddenByAnEnumeratorInTheSameScopeQuery()) and
  t.getClassOrEnumName() = c.getName() and
  // Occur in the same scope as the enum containing the constant
  t.getParentScope() = c.getDeclaringEnum().getParentScope() and
  // And in the same translation unit
  inSameTranslationUnit(t.getFile(), c.getFile())
select c, "Enumerator declaration $@ hides class or enumeration name $@", c, c.getName(), t,
  t.getClassOrEnumName()

/**
 * @id cpp/autosar/class-or-enumeration-name-hidden-by-a-function-in-the-same-scope
 * @name A2-10-6: Hiding of class or enumeration name by a function declaration in the same scope
 * @description A class or enumeration name shall not be hidden by a function declaration in the
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

from ClassOrEnum t, TopLevelFunction f
where
  not isExcluded(t, NamingPackage::classOrEnumerationNameHiddenByAFunctionInTheSameScopeQuery()) and
  not isExcluded(f, NamingPackage::classOrEnumerationNameHiddenByAFunctionInTheSameScopeQuery()) and
  t.getClassOrEnumName() = f.getName() and
  // Occur in the same scope
  t.getParentScope() = f.getParentScope() and
  // And in the same translation unit
  inSameTranslationUnit(t.getFile(), f.getFile())
select f, "Function declaration $@ hides class or enumeration name $@", f, f.getName(), t,
  t.getClassOrEnumName()

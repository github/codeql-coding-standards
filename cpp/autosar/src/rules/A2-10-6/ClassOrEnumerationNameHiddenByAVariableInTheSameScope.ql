/**
 * @id cpp/autosar/class-or-enumeration-name-hidden-by-a-variable-in-the-same-scope
 * @name A2-10-6: Hiding of class or enumeration name by a variable declaration in the same scope
 * @description A class or enumeration name shall not be hidden by a variable in the same scope.
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

from ClassOrEnum t, Variable v
where
  not isExcluded(t, NamingPackage::classOrEnumerationNameHiddenByAFunctionInTheSameScopeQuery()) and
  not isExcluded(v, NamingPackage::classOrEnumerationNameHiddenByAVariableInTheSameScopeQuery()) and
  // The class or enum has the same name as the variable
  t.getClassOrEnumName() = v.getName() and
  // Occur in the same scope
  t.getParentScope() = any(Scope s | s.getAVariable() = v) and
  // And in the same translation unit
  inSameTranslationUnit(t.getFile(), v.getFile())
select v, "Variable declaration $@ hides class or enumeration name $@", v, v.getName(), t,
  t.getClassOrEnumName()

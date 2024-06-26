/**
 * @id cpp/misra/inherited-overridable-member-function
 * @name RULE-6-4-2: Member function hides inherited member function
 * @description An overriding member function definition thats hides an overload of the overridden
 *              inherited member function can result in unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-4-2
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.hiddeninheritedoverridablememberfunction_shared.HiddenInheritedOverridableMemberFunction_shared

class InheritedOverridableMemberFunctionQuery extends HiddenInheritedOverridableMemberFunction_sharedSharedQuery {
  InheritedOverridableMemberFunctionQuery() {
    this = ImportMisra23Package::inheritedOverridableMemberFunctionQuery()
  }
}

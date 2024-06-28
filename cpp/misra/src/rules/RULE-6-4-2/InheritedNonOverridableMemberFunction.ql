/**
 * @id cpp/misra/inherited-non-overridable-member-function
 * @name RULE-6-4-2: Member function hides inherited member function
 * @description A non-overriding member function definition that hides an inherited member function
 *              can result in unexpected behavior.
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
import codingstandards.cpp.rules.hiddeninheritednonoverridablememberfunction_shared.HiddenInheritedNonOverridableMemberFunction_shared

class InheritedNonOverridableMemberFunctionQuery extends HiddenInheritedNonOverridableMemberFunction_sharedSharedQuery
{
  InheritedNonOverridableMemberFunctionQuery() {
    this = ImportMisra23Package::inheritedNonOverridableMemberFunctionQuery()
  }
}

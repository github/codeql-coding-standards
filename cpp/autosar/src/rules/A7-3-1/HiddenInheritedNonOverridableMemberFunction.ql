/**
 * @id cpp/autosar/hidden-inherited-non-overridable-member-function
 * @name A7-3-1: Member function hides inherited member function
 * @description A non-overriding member function definition that hides an inherited member function
 *              can result in unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a7-3-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.hiddeninheritednonoverridablememberfunction.HiddenInheritedNonOverridableMemberFunction

class HiddenInheritedNonOverridableMemberFunctionQuery extends HiddenInheritedNonOverridableMemberFunctionSharedQuery
{
  HiddenInheritedNonOverridableMemberFunctionQuery() {
    this = ScopePackage::hiddenInheritedNonOverridableMemberFunctionQuery()
  }
}

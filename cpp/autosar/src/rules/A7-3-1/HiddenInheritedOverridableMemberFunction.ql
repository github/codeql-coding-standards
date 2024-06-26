/**
 * @id cpp/autosar/hidden-inherited-overridable-member-function
 * @name A7-3-1: Member function hides inherited member function
 * @description An overriding member function definition thats hides an overload of the overridden
 *              inherited member function can result in unexpected behavior.
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
import codingstandards.cpp.rules.hiddeninheritedoverridablememberfunction_shared.HiddenInheritedOverridableMemberFunction_shared

class HiddenInheritedOverridableMemberFunctionQuery extends HiddenInheritedOverridableMemberFunction_sharedSharedQuery {
  HiddenInheritedOverridableMemberFunctionQuery() {
    this = ScopePackage::hiddenInheritedOverridableMemberFunctionQuery()
  }
}

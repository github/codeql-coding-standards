/**
 * @id cpp/autosar/state-related-to-function-object-identity-shall-not-be-copied
 * @name A25-1-1: State related to predicate function object's identity shall not be copied
 * @description Non-static data members or captured values of predicate function objects that are
 *              state related to this object's identity shall not be copied.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a25-1-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.predicatefunctionobjectsshouldnotbemutable.PredicateFunctionObjectsShouldNotBeMutable

class StateRelatedToFunctionObjectIdentityShallNotBeCopiedQuery extends PredicateFunctionObjectsShouldNotBeMutableSharedQuery {
  StateRelatedToFunctionObjectIdentityShallNotBeCopiedQuery() {
    this = SideEffects2Package::stateRelatedToFunctionObjectIdentityShallNotBeCopiedQuery()
  }
}

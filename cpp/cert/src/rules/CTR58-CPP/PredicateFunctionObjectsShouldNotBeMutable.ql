/**
 * @id cpp/cert/predicate-function-objects-should-not-be-mutable
 * @name CTR58-CPP: Predicate function objects should not be mutable
 * @description A mutable predicate function object passed to a C++ standard library algorithm may
 *              behave incorrectly because an algorithm can copy the predicate function object.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/ctr58-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p3
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.predicatefunctionobjectsshouldnotbemutable.PredicateFunctionObjectsShouldNotBeMutable

class PredicateFunctionObjectsShouldNotBeMutableQuery extends PredicateFunctionObjectsShouldNotBeMutableSharedQuery
{
  PredicateFunctionObjectsShouldNotBeMutableQuery() {
    this = SideEffects2Package::predicateFunctionObjectsShouldNotBeMutableQuery()
  }
}

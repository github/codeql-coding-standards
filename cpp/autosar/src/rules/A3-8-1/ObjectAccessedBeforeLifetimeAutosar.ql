/**
 * @id cpp/autosar/object-accessed-before-lifetime-autosar
 * @name A3-8-1: Access of uninitialized object
 * @description Accessing an object before its lifetime can result in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a3-8-1
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.objectaccessedbeforelifetime.ObjectAccessedBeforeLifetime

class ObjectAccessedBeforeLifetimeAutosarQuery extends ObjectAccessedBeforeLifetimeSharedQuery {
  ObjectAccessedBeforeLifetimeAutosarQuery() {
    this = FreedPackage::objectAccessedBeforeLifetimeAutosarQuery()
  }
}

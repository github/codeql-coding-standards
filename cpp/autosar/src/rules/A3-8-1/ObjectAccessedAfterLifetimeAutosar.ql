/**
 * @id cpp/autosar/object-accessed-after-lifetime-autosar
 * @name A3-8-1: Access of object after lifetime (use-after-free)
 * @description Accessing an object after its lifetime results in undefined behavior.
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
import codingstandards.cpp.rules.objectaccessedafterlifetime.ObjectAccessedAfterLifetime

class ObjectAccessedAfterLifetimeAutosarQuery extends ObjectAccessedAfterLifetimeSharedQuery {
  ObjectAccessedAfterLifetimeAutosarQuery() {
    this = FreedPackage::objectAccessedAfterLifetimeAutosarQuery()
  }
}

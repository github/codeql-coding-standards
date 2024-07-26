/**
 * @id cpp/misra/object-accessed-before-lifetime-misra
 * @name RULE-6-8-1: Access of uninitialized object
 * @description Accessing an object before its lifetime can result in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-6-8-1
 *       correctness
 *       security
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.objectaccessedbeforelifetime.ObjectAccessedBeforeLifetime

class ObjectAccessedBeforeLifetimeMisraQuery extends ObjectAccessedBeforeLifetimeSharedQuery {
  ObjectAccessedBeforeLifetimeMisraQuery() {
    this = ImportMisra23Package::objectAccessedBeforeLifetimeMisraQuery()
  }
}

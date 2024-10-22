/**
 * @id cpp/misra/object-accessed-after-lifetime-misra
 * @name RULE-6-8-1: Access of object after lifetime (use-after-free)
 * @description Accessing an object after its lifetime results in undefined behavior.
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
import codingstandards.cpp.rules.objectaccessedafterlifetime.ObjectAccessedAfterLifetime

class ObjectAccessedAfterLifetimeMisraQuery extends ObjectAccessedAfterLifetimeSharedQuery {
  ObjectAccessedAfterLifetimeMisraQuery() {
    this = ImportMisra23Package::objectAccessedAfterLifetimeMisraQuery()
  }
}

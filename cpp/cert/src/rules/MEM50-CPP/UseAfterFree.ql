/**
 * @id cpp/cert/use-after-free
 * @name MEM50-CPP: Do not access freed memory
 * @description Accessing an object after it has been deallocated is undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/mem50-cpp
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.objectaccessedafterlifetime.ObjectAccessedAfterLifetime

class ObjectAccessedAfterLifetimeCertQuery extends ObjectAccessedAfterLifetimeSharedQuery {
  ObjectAccessedAfterLifetimeCertQuery() { this = FreedPackage::useAfterFreeQuery() }
}

/**
 * @id cpp/cert/object-accessed-after-lifetime-cert
 * @name EXP54-CPP: Access of object after lifetime (use-after-free)
 * @description Accessing an object after its lifetime results in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp54-cpp
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.objectaccessedafterlifetime.ObjectAccessedAfterLifetime

class ObjectAccessedAfterLifetimeCertQuery extends ObjectAccessedAfterLifetimeSharedQuery {
  ObjectAccessedAfterLifetimeCertQuery() {
    this = FreedPackage::objectAccessedAfterLifetimeCertQuery()
  }
}

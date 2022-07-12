/**
 * @id cpp/cert/object-accessed-before-lifetime-cert
 * @name EXP54-CPP: Access of uninitialized object
 * @description Accessing an object before its lifetime can result in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp54-cpp
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.objectaccessedbeforelifetime.ObjectAccessedBeforeLifetime

class ObjectAccessedBeforeLifetimeCertQuery extends ObjectAccessedBeforeLifetimeSharedQuery {
  ObjectAccessedBeforeLifetimeCertQuery() {
    this = FreedPackage::objectAccessedBeforeLifetimeCertQuery()
  }
}

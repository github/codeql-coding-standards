/**
 * @id cpp/cert/prevent-bit-field-access-from-multiple-threads
 * @name CON52-CPP: Prevent data races when accessing bit-fields from multiple threads
 * @description Accesses to bit fields without proper concurrency protection can result in data
 *              races.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con52-cpp
 *       correctness
 *       concurrency
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p8
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.guardaccesstobitfields.GuardAccessToBitFields

class PreventBitFieldAccessFromMultipleThreadsQuery extends GuardAccessToBitFieldsSharedQuery {
  PreventBitFieldAccessFromMultipleThreadsQuery() {
    this = ConcurrencyPackage::preventBitFieldAccessFromMultipleThreadsQuery()
  }
}

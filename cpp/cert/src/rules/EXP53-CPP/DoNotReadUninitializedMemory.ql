/**
 * @id cpp/cert/do-not-read-uninitialized-memory
 * @name EXP53-CPP: Do not read uninitialized memory
 * @description Reading from uninitialized indeterminate values may produce undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/exp53-cpp
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p12
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.readofuninitializedmemory.ReadOfUninitializedMemory

class DoNotReadUninitializedMemoryQuery extends ReadOfUninitializedMemorySharedQuery {
  DoNotReadUninitializedMemoryQuery() {
    this = UninitializedPackage::doNotReadUninitializedMemoryQuery()
  }
}

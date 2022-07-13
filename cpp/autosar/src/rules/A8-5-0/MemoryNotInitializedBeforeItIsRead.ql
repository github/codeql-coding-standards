/**
 * @id cpp/autosar/memory-not-initialized-before-it-is-read
 * @name A8-5-0: All memory shall be initialized before it is read
 * @description Reading from uninitialized indeterminate values may produce undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/autosar/id/a8-5-0
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.readofuninitializedmemory.ReadOfUninitializedMemory

class MemoryNotInitializedBeforeItIsReadQuery extends ReadOfUninitializedMemorySharedQuery {
  MemoryNotInitializedBeforeItIsReadQuery() {
    this = UninitializedPackage::memoryNotInitializedBeforeItIsReadQuery()
  }
}

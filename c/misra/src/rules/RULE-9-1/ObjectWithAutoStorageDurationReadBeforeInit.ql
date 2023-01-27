/**
 * @id c/misra/object-with-auto-storage-duration-read-before-init
 * @name RULE-9-1: The value of an object with automatic storage duration shall not be read before it has been set
 * @description Accessing an object before it has been initialized can lead to undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-9-1
 *       correctness
 *       security
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.readofuninitializedmemory.ReadOfUninitializedMemory

class ObjectWithAutoStorageDurationReadBeforeInitQuery extends ReadOfUninitializedMemorySharedQuery {
  ObjectWithAutoStorageDurationReadBeforeInitQuery() {
    this = InvalidMemory1Package::objectWithAutoStorageDurationReadBeforeInitQuery()
  }
}

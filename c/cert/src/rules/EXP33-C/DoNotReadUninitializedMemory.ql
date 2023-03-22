/**
 * @id c/cert/do-not-read-uninitialized-memory
 * @name EXP33-C: Do not read uninitialized memory
 * @description Using the value of an object with automatic storage duration while it is
 *              indeterminate is undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/exp33-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.readofuninitializedmemory.ReadOfUninitializedMemory

class DoNotReadUninitializedMemoryQuery extends ReadOfUninitializedMemorySharedQuery {
  DoNotReadUninitializedMemoryQuery() {
    this = InvalidMemory1Package::doNotReadUninitializedMemoryQuery()
  }
}

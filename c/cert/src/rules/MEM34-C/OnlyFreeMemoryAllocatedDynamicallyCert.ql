/**
 * @id c/cert/only-free-memory-allocated-dynamically-cert
 * @name MEM34-C: Only free memory allocated dynamically
 * @description Freeing memory that is not allocated dynamically can lead to heap corruption and
 *              undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/mem34-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.onlyfreememoryallocateddynamicallyshared.OnlyFreeMemoryAllocatedDynamicallyShared

class OnlyFreeMemoryAllocatedDynamicallyCertQuery extends OnlyFreeMemoryAllocatedDynamicallySharedSharedQuery {
  OnlyFreeMemoryAllocatedDynamicallyCertQuery() {
    this = Memory2Package::onlyFreeMemoryAllocatedDynamicallyCertQuery()
  }
}

/**
 * @id c/misra/only-free-memory-allocated-dynamically-misra
 * @name RULE-22-2: A block of memory shall only be freed if it was allocated by means of a Standard Library function
 * @description Freeing memory that is not allocated dynamically can lead to heap corruption and
 *              undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-22-2
 *       correctness
 *       security
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.onlyfreememoryallocateddynamicallyshared.OnlyFreeMemoryAllocatedDynamicallyShared

class OnlyFreeMemoryAllocatedDynamicallyMisraQuery extends OnlyFreeMemoryAllocatedDynamicallySharedSharedQuery {
  OnlyFreeMemoryAllocatedDynamicallyMisraQuery() {
    this = Memory2Package::onlyFreeMemoryAllocatedDynamicallyMisraQuery()
  }
}

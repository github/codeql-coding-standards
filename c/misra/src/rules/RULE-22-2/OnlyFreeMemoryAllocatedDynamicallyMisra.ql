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
 *       external/misra/c/2012/third-edition-first-revision
 *       external/cwe/cwe-119
 *       external/cwe/cwe-401
 *       external/cwe/cwe-415
 *       external/cwe/cwe-416
 *       external/cwe/cwe-590
 *       external/cwe/cwe-680
 *       external/cwe/cwe-761
 *       external/cwe/cwe-762
 *       external/cwe/cwe-763
 *       external/cwe/cwe-825
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.onlyfreememoryallocateddynamicallyshared.OnlyFreeMemoryAllocatedDynamicallyShared

class OnlyFreeMemoryAllocatedDynamicallyMisraQuery extends OnlyFreeMemoryAllocatedDynamicallySharedSharedQuery
{
  OnlyFreeMemoryAllocatedDynamicallyMisraQuery() {
    this = Memory2Package::onlyFreeMemoryAllocatedDynamicallyMisraQuery()
  }
}

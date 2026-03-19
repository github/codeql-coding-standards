/**
 * @id cpp/cert/properly-deallocate-dynamically-allocated-resources
 * @name MEM51-CPP: Properly deallocate dynamically allocated resources
 * @description Deallocation functions should only be called on nullptr or a pointer returned by the
 *              corresponding allocation function, that hasn't already been deallocated.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/mem51-cpp
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.properlydeallocatedynamicallyallocatedresourcesshared.ProperlyDeallocateDynamicallyAllocatedResourcesShared

module ProperlyDeallocateDynamicallyAllocatedResourcesConfig implements
  ProperlyDeallocateDynamicallyAllocatedResourcesSharedConfigSig
{
  Query getQuery() {
    result = AllocationsPackage::properlyDeallocateDynamicallyAllocatedResourcesQuery()
  }
}

import ProperlyDeallocateDynamicallyAllocatedResourcesShared<ProperlyDeallocateDynamicallyAllocatedResourcesConfig>

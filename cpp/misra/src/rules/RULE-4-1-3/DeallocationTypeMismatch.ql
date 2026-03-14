/**
 * @id cpp/misra/deallocation-type-mismatch
 * @name RULE-4-1-3: Deallocation type mismatch leads to undefined behavior
 * @description Using a deallocation function that does not match the allocation function results in
 *              undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-3
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.properlydeallocatedynamicallyallocatedresourcesshared.ProperlyDeallocateDynamicallyAllocatedResourcesShared

module DeallocationTypeMismatchConfig implements
  ProperlyDeallocateDynamicallyAllocatedResourcesSharedConfigSig
{
  Query getQuery() { result = UndefinedPackage::deallocationTypeMismatchQuery() }
}

import ProperlyDeallocateDynamicallyAllocatedResourcesShared<DeallocationTypeMismatchConfig>

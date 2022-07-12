/**
 * @id cpp/autosar/dynamic-memory-management-failure-mode
 * @name A18-5-6: (Audit) An analysis shall be performed to analyze the failure modes of dynamic memory management
 * @description An analysis shall be performed to analyze the failure modes of dynamic memory
 *              management.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a18-5-6
 *       correctness
 *       external/autosar/allocated-target/verification
 *       external/autosar/allocated-target/toolchain
 *       external/autosar/audit
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.allocations.UserDefinedMemoryAllocator

/*
 * This query is an audit query that identifies likely memory allocation
 * functions. It works by reporting functions explicitly installed as a
 * `new_function_handler` as well as looking at the corresponding clang
 * attributes.
 */

from UserDefinedMemoryAllocator ma
where not isExcluded(ma, AllocationsPackage::dynamicMemoryManagementFailureModeQuery())
select ma,
  "(Audit) Function may be a memory allocation function and an analysis should be performed to analyze the failure modes of dynamic memory management."

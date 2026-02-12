/**
 * @id cpp/misra/advanced-memory-management-used
 * @name RULE-21-6-3: Advanced memory management shall not be used
 * @description Using advanced memory management that either alters allocation and deallocation or
 *              constructs object construction on uninitalized memory may result in undefined
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-6-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, Memory6Package::advancedMemoryManagementUsedQuery()) and
select

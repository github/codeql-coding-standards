/**
 * @id cpp/misra/dynamic-memory-managed-manually
 * @name RULE-21-6-2: Dynamic memory shall be managed automatically
 * @description Dynamically allocated memory must not be managed manually.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-6-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, Memory5Package::dynamicMemoryManagedManuallyQuery()) and
select

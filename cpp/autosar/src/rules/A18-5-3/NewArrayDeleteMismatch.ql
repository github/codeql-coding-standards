/**
 * @id cpp/autosar/new-array-delete-mismatch
 * @name A18-5-3: 'new[]' array freed with 'delete'
 * @description An array allocated with 'new[]' is being freed using 'delete'. Behavior in such
 *              cases is undefined and should be avoided. Use 'delete[]' when freeing arrays
 *              allocated with 'new[]'.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a18-5-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Allocations

from Expr alloc, Expr free, Expr freed
where
  not isExcluded(alloc, FreedPackage::newArrayDeleteMismatchQuery()) and
  allocReaches(freed, alloc, "new[]") and
  freeExprOrIndirect(free, freed, "delete")
select free, "This memory may have been allocated with '$@', not 'new'.", alloc, "new[]"

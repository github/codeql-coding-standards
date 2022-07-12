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
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Allocations

predicate matching(string allocKind, string deleteKind) {
  allocKind = "new" and deleteKind = "delete"
  or
  allocKind = "new[]" and deleteKind = "delete[]"
  or
  allocKind = "malloc" and deleteKind = "free"
}

from Expr alloc, Expr free, Expr freed, string allocKind, string deleteKind
where
  not isExcluded(freed, FreedPackage::newDeleteArrayMismatchQuery()) and
  allocReaches(freed, alloc, allocKind) and
  freeExprOrIndirect(free, freed, deleteKind) and
  not matching(allocKind, deleteKind)
select free, "Memory allocated with $@ but deleted with " + deleteKind + ".", alloc, allocKind

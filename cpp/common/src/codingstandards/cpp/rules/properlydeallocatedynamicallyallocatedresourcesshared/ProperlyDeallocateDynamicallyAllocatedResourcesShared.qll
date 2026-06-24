/**
 * Provides a configurable module ProperlyDeallocateDynamicallyAllocatedResourcesShared with a
 * `problems` predicate for the following issue:
 * Deallocation functions should only be called on nullptr or a pointer returned by the
 * corresponding allocation function, that hasn't already been deallocated.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Allocations

signature module ProperlyDeallocateDynamicallyAllocatedResourcesSharedConfigSig {
  Query getQuery();
}

module ProperlyDeallocateDynamicallyAllocatedResourcesShared<
  ProperlyDeallocateDynamicallyAllocatedResourcesSharedConfigSig Config>
{
  private predicate matching(string allocKind, string deleteKind) {
    allocKind = "new" and deleteKind = "delete"
    or
    allocKind = "new[]" and deleteKind = "delete[]"
    or
    allocKind = "malloc" and deleteKind = "free"
  }

  query predicate problems(Expr free, string message, Expr alloc, string allocKind) {
    exists(Expr freed, string deleteKind |
      not isExcluded(freed, Config::getQuery()) and
      allocReaches(freed, alloc, allocKind) and
      freeExprOrIndirect(free, freed, deleteKind) and
      not matching(allocKind, deleteKind) and
      message = "Memory allocated with $@ but deleted with " + deleteKind + "."
    )
  }
}

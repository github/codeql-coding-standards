/**
 * Provides a library which includes a `problems` predicate for reporting custom overrides of
 * `operator delete` where the user has not overloaded both the sized and non-sized versions.
 */

import cpp
import codingstandards.cpp.allocations.CustomOperatorNewDelete
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class OperatorDeleteMissingPartnerSharedQuery extends Query { }

Query getQuery() { result instanceof OperatorDeleteMissingPartnerSharedQuery }

/*
 * Must override both or neither
 * void operator delete(void* ptr) noexcept;
 * void operator delete(void* ptr, std::size_t size) noexcept;
 */

/*
 * Must override both or neither
 * void operator delete(void*, const std::nothrow_t&)
 * void operator delete(void*, std::size_t, const std::nothrow_t&)
 */

/*
 * Must override both or neither
 * void operator delete[](void*)
 * void operator delete[](void*, std::size_t)
 */

/*
 * Must override both or neither
 * void operator delete[](void*, const std::nothrow_t&)
 * void operator delete[](void*, std::size_t, const std::nothrow_t&)
 */

query predicate problems(CustomOperatorDelete cd, string message) {
  not isExcluded(cd, getQuery()) and
  not exists(cd.getPartner()) and
  if cd.getAParameter().getType() instanceof Size_t
  then
    message =
      "Custom " + cd.getAllocDescription() + " is missing overload that does not take std::size_t."
  else
    message = "Custom " + cd.getAllocDescription() + " is missing overload that takes std::size_t."
}

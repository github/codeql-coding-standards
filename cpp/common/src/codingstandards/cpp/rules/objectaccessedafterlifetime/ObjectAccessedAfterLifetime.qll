/**
 * Provides a library which includes a `problems` predicate for reporting reporting issues with objects
 * accessed after their lifetime has finished.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.lifetimes.lifetimeprofile.LifetimeProfile

abstract class ObjectAccessedAfterLifetimeSharedQuery extends Query { }

Query getQuery() { result instanceof ObjectAccessedAfterLifetimeSharedQuery }

query predicate problems(
  InvalidDereference e, string message, Element explanation, string explanationDesc
) {
  not isExcluded(e, getQuery()) and
  exists(InvalidReason ir, string invalidMessage |
    ir = e.getAnInvalidReason() and
    ir.isAfterLifetime() and
    ir.hasMessage(invalidMessage, explanation, explanationDesc) and
    message =
      e.(VariableAccess).getTarget().getName() +
        " is dereferenced here but accesses invalid memory " + invalidMessage
  )
}

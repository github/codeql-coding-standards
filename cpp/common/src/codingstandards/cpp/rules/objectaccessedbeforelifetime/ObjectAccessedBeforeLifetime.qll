/**
 * Provides a library which includes a `problems` predicate for reporting issues with objects
 * accessed before their lifetime has started.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.lifetimes.lifetimeprofile.LifetimeProfile

abstract class ObjectAccessedBeforeLifetimeSharedQuery extends Query { }

Query getQuery() { result instanceof ObjectAccessedBeforeLifetimeSharedQuery }

query predicate problems(
  InvalidDereference e, string message, Element explanation, string explanationDesc
) {
  not isExcluded(e, getQuery()) and
  exists(InvalidReason ir, string invalidMessage |
    ir = e.getAnInvalidReason() and
    ir.isBeforeLifetime() and
    ir.hasMessage(invalidMessage, explanation, explanationDesc) and
    message =
      e.(VariableAccess).getTarget().getName() + " is dereferenced here but is invalid " +
        invalidMessage
  )
}

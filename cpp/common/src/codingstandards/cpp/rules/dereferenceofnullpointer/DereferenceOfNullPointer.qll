/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.lifetimes.lifetimeprofile.LifetimeProfile

abstract class DereferenceOfNullPointerSharedQuery extends Query { }

Query getQuery() { result instanceof DereferenceOfNullPointerSharedQuery }

query predicate problems(
  NullDereference nd, string message, Element explanation, string explanationDesc
) {
  not isExcluded(nd, getQuery()) and
  exists(NullReason nr, string nullMessage |
    nr = nd.getAnInvalidReason() and
    nr.hasMessage(nullMessage, explanation, explanationDesc) and
    message = "Null may be dereferenced here " + nullMessage
  )
}

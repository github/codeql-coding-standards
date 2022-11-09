/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Identifiers

abstract class NotDistinctIdentifierSharedQuery extends Query { }

Query getQuery() { result instanceof NotDistinctIdentifierSharedQuery }

query predicate problems(
  ExternalIdentifiers d, string message, ExternalIdentifiers d2, string nameplaceholder
) {
  not isExcluded(d, getQuery()) and
  not isExcluded(d2, getQuery()) and
  d.getName().length() >= 31 and
  d2.getName().length() >= 31 and
  not d = d2 and
  d.getLocation().getStartLine() >= d2.getLocation().getStartLine() and
  d.getSignificantName() = d2.getSignificantName() and
  not d.getName() = d2.getName() and
  nameplaceholder = d2.getName() and
  message =
    "External identifer " + d.getName() +
      " is nondistinct in characters at or over 31 limit, compared to $@"
}

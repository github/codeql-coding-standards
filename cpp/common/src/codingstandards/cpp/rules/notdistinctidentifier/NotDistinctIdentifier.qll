/**
 * Provides a library with a `problems` predicate for the following issue:
 * Using nondistinct external identifiers results in undefined behaviour.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Identifiers

abstract class NotDistinctIdentifierSharedQuery extends Query { }

Query getQuery() { result instanceof NotDistinctIdentifierSharedQuery }

bindingset[d, d2]
pragma[inline_late]
private predicate after(ExternalIdentifiers d, ExternalIdentifiers d2) {
  exists(int dStartLine, int d2StartLine |
    d.getLocation().hasLocationInfo(_, dStartLine, _, _, _) and
    d2.getLocation().hasLocationInfo(_, d2StartLine, _, _, _) and
    dStartLine >= d2StartLine
  )
}

query predicate problems(
  ExternalIdentifiers d, string message, ExternalIdentifiers d2, string nameplaceholder
) {
  not isExcluded(d, getQuery()) and
  not isExcluded(d2, getQuery()) and
  d.getName().length() >= 31 and
  d2.getName().length() >= 31 and
  not d = d2 and
  d.getSignificantName() = d2.getSignificantName() and
  not d.getName() = d2.getName() and
  nameplaceholder = d2.getName() and
  after(d, d2) and
  message =
    "External identifer " + d.getName() +
      " is nondistinct in characters at or over 31 limit, compared to $@"
}

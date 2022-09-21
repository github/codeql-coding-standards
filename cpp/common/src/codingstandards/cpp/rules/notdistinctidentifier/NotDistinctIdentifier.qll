/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Linkage

class ExternalIdentifiers extends Declaration {
  ExternalIdentifiers() {
    this.getName().length() >= 31 and
    hasExternalLinkage(this) and
    getNamespace() instanceof GlobalNamespace and
    not this.isFromTemplateInstantiation(_) and
    not this.isFromUninstantiatedTemplate(_) and
    not this.hasDeclaringType() and
    not this instanceof UserType and
    not this instanceof Operator and
    not this.hasName("main")
  }

  string getSignificantName() {
    //C99 states the first 31 characters of external identifiers are significant
    //C90 states the first 6 characters of external identifiers are significant and case is not required to be significant
    //C90 is not currently considered by this rule
    result = this.getName().prefix(31)
  }
}

abstract class NotDistinctIdentifierSharedQuery extends Query { }

Query getQuery() { result instanceof NotDistinctIdentifierSharedQuery }

query predicate problems(ExternalIdentifiers d, ExternalIdentifiers d2, string message) {
  not isExcluded(d, getQuery()) and
  not isExcluded(d, getQuery()) and
  not d = d2 and
  d.getLocation().getStartLine() >= d2.getLocation().getStartLine() and
  d.getSignificantName() = d2.getSignificantName() and
  not d.getName() = d2.getName() and
  message =
    "External identifer " + d.getName() +
      " is nondistinct in characters at or over 31 limit, compared to " + d2.getName()
}

/**
 * @id c/misra/external-identifiers-not-distinct
 * @name RULE-5-1: External identifiers shall be distinct
 * @description Using nondistinct external identifiers results in undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-5-1
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Linkage

class ExternalIdentifiers extends Declaration {
  ExternalIdentifiers() { hasExternalLinkage(this) }

  string getSignificantName() {
    //C99 states the first 31 characters of external identifiers are significant
    //C90 states the first 6 characters of external identifiers are significant and case is not required to be significant
    //C90 is not currently considered by this rule
    result = this.getName().prefix(31)
  }
}

from ExternalIdentifiers d, ExternalIdentifiers d2
where
  not isExcluded(d, Declarations1Package::externalIdentifiersNotDistinctQuery()) and
  not d = d2 and
  d.getLocation().getStartLine() >= d2.getLocation().getStartLine() and
  d.getSignificantName() = d2.getSignificantName()
select d,
  "External identifer " + d.getName() + " is nondistinct in first 31 characters, compared to $@.",
  d2, d2.getName()

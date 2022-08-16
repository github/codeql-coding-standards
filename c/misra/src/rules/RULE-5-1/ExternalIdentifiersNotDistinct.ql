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

from ExternalIdentifiers d, ExternalIdentifiers d2
where
  not isExcluded(d, Declarations1Package::externalIdentifiersNotDistinctQuery()) and
  not d = d2 and
  d.getLocation().getStartLine() >= d2.getLocation().getStartLine() and
  d.getSignificantName() = d2.getSignificantName() and
  not d.getName() = d2.getName()
select d,
  "External identifer " + d.getName() +
    " is nondistinct in characters at or over 31 limit, compared to $@.", d2, d2.getName()

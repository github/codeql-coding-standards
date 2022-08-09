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
}

class ExternalIdentifiersLong extends ExternalIdentifiers {
  ExternalIdentifiersLong() { this.getName().length() >= 32 }
}

predicate notSame(ExternalIdentifiers d, ExternalIdentifiers d2) { not d = d2 }

from ExternalIdentifiers d, ExternalIdentifiers d2
where
  not isExcluded(d, Declarations1Package::externalIdentifiersNotDistinctQuery()) and
  notSame(d, d2) and
  if d instanceof ExternalIdentifiersLong and d2 instanceof ExternalIdentifiersLong
  then d.getName().substring(0, 30) = d2.getName().substring(0, 30)
  else d.getName() = d2.getName()
select d, "External identifer is nondistinct " + d.getName() + " compared to $@.", d2, d.getName()

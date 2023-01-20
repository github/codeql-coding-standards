/**
 * @id c/misra/identifiers-declared-in-the-same-scope-not-distinct
 * @name RULE-5-2: Identifiers declared in the same scope and name space shall be distinct
 * @description Using nondistinct identifiers results in undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-5-2
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers

from InterestingIdentifiers d, InterestingIdentifiers d2
where
  not isExcluded(d, Declarations5Package::identifiersDeclaredInTheSameScopeNotDistinctQuery()) and
  not isExcluded(d2, Declarations5Package::identifiersDeclaredInTheSameScopeNotDistinctQuery()) and
  //this rule does not apply if both are external identifiers
  //that is covered by RULE-5-3
  not (
    d instanceof ExternalIdentifiers and
    d2 instanceof ExternalIdentifiers
  ) and
  d.getNamespace() = d2.getNamespace() and
  d.getParentScope() = d2.getParentScope() and
  not d = d2 and
  d.getLocation().getStartLine() >= d2.getLocation().getStartLine() and
  //first 63 chars in the name as per C99
  d.getSignificantNameComparedToMacro() = d2.getSignificantNameComparedToMacro() and
  not d.getName() = d2.getName()
select d,
  "Identifer " + d.getName() + " is nondistinct in characters at or over 63 limit, compared to $@",
  d2, d2.getName()

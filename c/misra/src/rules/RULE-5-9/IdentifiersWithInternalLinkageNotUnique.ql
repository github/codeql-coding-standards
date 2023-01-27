/**
 * @id c/misra/identifiers-with-internal-linkage-not-unique
 * @name RULE-5-9: Identifiers that define objects or functions with internal linkage should be unique
 * @description Using non-unique identifiers can lead to developer confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-9
 *       maintainability
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from Declaration d1, Declaration d2
where
  not isExcluded(d1, Declarations6Package::identifiersWithInternalLinkageNotUniqueQuery()) and
  not isExcluded(d2, Declarations6Package::identifiersWithInternalLinkageNotUniqueQuery()) and
  d1.isStatic() and
  d1.isTopLevel() and
  not d1 = d2 and
  d1.getName() = d2.getName() and
  // Apply an ordering based on location to enforce that (d1, d2) = (d2, d1) and we only report (d1, d2).
  (
    d1.getFile().getAbsolutePath() < d2.getFile().getAbsolutePath()
    or
    d1.getFile().getAbsolutePath() = d2.getFile().getAbsolutePath() and
    d1.getLocation().getStartLine() < d2.getLocation().getStartLine()
  )
select d2, "Identifier conflicts with identifier $@ with internal linkage.", d1, d1.getName()

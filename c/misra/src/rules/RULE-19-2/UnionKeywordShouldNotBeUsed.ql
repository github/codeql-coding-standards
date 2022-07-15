/**
 * @id c/misra/union-keyword-should-not-be-used
 * @name RULE-19-2: The 'union' keyword should not be used
 * @description The use of 'union' may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-19-2
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from Union u
where not isExcluded(u, BannedPackage::unionKeywordShouldNotBeUsedQuery())
select u, "Use of banned 'union' keyword."

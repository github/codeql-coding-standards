/**
 * @id c/misra/restrict-type-qualifier-used
 * @name RULE-8-14: The restrict type qualifier shall not be used
 * @description The use of the 'restrict' type qualifier may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-14
 *       correctness
 *       security
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Variable v
where
  not isExcluded(v, BannedPackage::restrictTypeQualifierUsedQuery()) and
  v.getType().getASpecifier().hasName("restrict")
select v, "Use of banned 'restrict' type qualifier on $@.", v, v.getName()

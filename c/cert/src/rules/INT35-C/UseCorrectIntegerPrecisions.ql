/**
 * @id c/cert/use-correct-integer-precisions
 * @name INT35-C: Use correct integer precisions
 * @description TODO.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/int35-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, TypesPackage::useCorrectIntegerPrecisionsQuery()) and
select

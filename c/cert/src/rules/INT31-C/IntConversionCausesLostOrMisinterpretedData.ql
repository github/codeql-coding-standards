/**
 * @id c/cert/int-conversion-causes-lost-or-misinterpreted-data
 * @name INT31-C: Ensure that integer conversions do not result in lost or misinterpreted data
 * @description TODO.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/int31-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, TypesPackage::intConversionCausesLostOrMisinterpretedDataQuery()) and
select

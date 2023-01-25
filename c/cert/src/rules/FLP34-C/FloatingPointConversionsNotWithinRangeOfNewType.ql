/**
 * @id c/cert/floating-point-conversions-not-within-range-of-new-type
 * @name FLP34-C: Ensure that floating-point conversions are within range of the new type
 * @description TODO.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/flp34-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, TypesPackage::floatingPointConversionsNotWithinRangeOfNewTypeQuery()) and
select

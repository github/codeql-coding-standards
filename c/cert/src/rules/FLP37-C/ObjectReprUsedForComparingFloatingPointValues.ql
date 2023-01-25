/**
 * @id c/cert/object-repr-used-for-comparing-floating-point-values
 * @name FLP37-C: Do not use object representations to compare floating-point values
 * @description TODO.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/flp37-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, TypesPackage::objectReprUsedForComparingFloatingPointValuesQuery()) and
select

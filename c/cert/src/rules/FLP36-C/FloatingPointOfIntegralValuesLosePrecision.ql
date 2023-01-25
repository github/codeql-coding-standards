/**
 * @id c/cert/floating-point-of-integral-values-lose-precision
 * @name FLP36-C: Preserve precision when converting integral values to floating-point type
 * @description TODO.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/flp36-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, TypesPackage::floatingPointOfIntegralValuesLosePrecisionQuery()) and
select

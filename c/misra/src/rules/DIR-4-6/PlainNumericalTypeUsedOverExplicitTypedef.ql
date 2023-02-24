/**
 * @id c/misra/plain-numerical-type-used-over-explicit-typedef
 * @name DIR-4-6: Do not use plain numerical types over typedefs named after their explicit bit layout
 * @description Using plain numerical types over typedefs with explicit sign and bit counts may lead
 *              to confusion on how much bits are allocated for a value.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/dir-4-6
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::plainNumericalTypeUsedOverExplicitTypedefQuery()) and
select

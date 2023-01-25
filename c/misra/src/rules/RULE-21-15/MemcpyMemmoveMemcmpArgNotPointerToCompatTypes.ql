/**
 * @id c/misra/memcpy-memmove-memcmp-arg-not-pointer-to-compat-types
 * @name RULE-21-15: The pointer arguments to the Standard Library functions memcpy, memmove and memcmp shall be pointers
 * @description The pointer arguments to the Standard Library functions memcpy, memmove and memcmp
 *              shall be pointers to qualified or unqualified versions of compatible types.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-15
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::memcpyMemmoveMemcmpArgNotPointerToCompatTypesQuery()) and
select

/**
 * @id c/misra/memcpy-memmove-memcmp-arg-not-pointers-to-compatible-types
 * @name RULE-21-15: The pointer arguments to the Standard Library functions memcpy, memmove and memcmp shall be pointers
 * @description Passing pointers to incompatible types as arguments to memcpy, memmove and memcmp
 *              indicates programmers' confusion.
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
  not isExcluded(x, StandardLibraryFunctionTypesPackage::memcpyMemmoveMemcmpArgNotPointersToCompatibleTypesQuery()) and
select

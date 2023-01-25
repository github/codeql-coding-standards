/**
 * @id c/cert/converting-a-pointer-to-integer-or-integer-to-pointer
 * @name INT36-C: Converting a pointer to integer or integer to pointer
 * @description TODO.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/int36-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, TypesPackage::convertingAPointerToIntegerOrIntegerToPointerQuery()) and
select

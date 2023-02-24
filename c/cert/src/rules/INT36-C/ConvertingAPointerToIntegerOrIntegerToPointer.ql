/**
 * @id c/cert/converting-a-pointer-to-integer-or-integer-to-pointer
 * @name INT36-C: Do not convert pointers to integers and back
 * @description Converting between pointers and integers is not portable and might cause invalid
 *              memory access.
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

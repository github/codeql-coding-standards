/**
 * @id c/misra/memcmp-used-to-compare-null-terminated-strings
 * @name RULE-21-14: The Standard Library function memcmp shall not be used to compare null terminated strings
 * @description TODO.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-21-14
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::memcmpUsedToCompareNullTerminatedStringsQuery()) and
select

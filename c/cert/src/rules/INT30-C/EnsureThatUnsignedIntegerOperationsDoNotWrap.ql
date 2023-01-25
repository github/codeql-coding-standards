/**
 * @id c/cert/ensure-that-unsigned-integer-operations-do-not-wrap
 * @name INT30-C: Ensure that unsigned integer operations do not wrap
 * @description TODO.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/int30-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, TypesPackage::ensureThatUnsignedIntegerOperationsDoNotWrapQuery()) and
select

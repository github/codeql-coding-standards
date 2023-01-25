/**
 * @id c/cert/operations-on-signed-integers-results-in-overflow
 * @name INT32-C: Ensure that operations on signed integers do not result in overflow
 * @description TODO.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/int32-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, TypesPackage::operationsOnSignedIntegersResultsInOverflowQuery()) and
select

/**
 * @id c/cert/div-and-mod-operation-results-in-div-by-zero
 * @name INT33-C: Ensure that division and remainder operations do not result in divide-by-zero errors
 * @description TODO.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/int33-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, TypesPackage::divAndModOperationResultsInDivByZeroQuery()) and
select

/**
 * @id c/cert/prevent-or-detect-domain-and-range-errors-in-math-functions
 * @name FLP32-C: Prevent or detect domain and range errors in math functions
 * @description TODO.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/flp32-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, TypesPackage::preventOrDetectDomainAndRangeErrorsInMathFunctionsQuery()) and
select

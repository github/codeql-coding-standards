/**
 * @id c/misra/plain-integer-type-used-over-explicit-typedef
 * @name DIR-4-6: Plain integer types should use explicit typedefs
 * @description Using integer typedefs makes their size and signedness explicit.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/dir-4-6
 *       external/misra/c/2025
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.PlainNumericalTypes

from Element element, string message
where
  not isExcluded(element, Types1Package::plainIntegerTypeUsedOverExplicitTypedefQuery()) and
  problems(element, message) and
  not hasFloatingType(element)
select element, message

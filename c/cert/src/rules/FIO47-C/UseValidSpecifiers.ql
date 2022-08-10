/**
 * @id c/cert/use-valid-specifiers
 * @name FIO47-C: Use valid format strings
 * @description Use valid conversion specifier
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio47-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

class InvalidSpecifier extends FormatLiteral {
  InvalidSpecifier() { not this.specsAreKnown() }
}

from InvalidSpecifier x
where not isExcluded(x, IO4Package::useValidSpecifiersQuery())
select x, "The conversion specifier '" + x + "' is not valid."

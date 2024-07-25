/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CastCharBeforeConvertingToLargerSizesSharedQuery extends Query { }

Query getQuery() { result instanceof CastCharBeforeConvertingToLargerSizesSharedQuery }

query predicate problems(Cast c, string message) {
  not isExcluded(c, getQuery()) and
  // find cases where there is a conversion happening wherein the
  // base type is a char
  c.getExpr().getType() instanceof CharType and
  not c.getExpr().getType() instanceof UnsignedCharType and
  // it's a bigger type
  c.getType().getSize() > c.getExpr().getType().getSize() and
  // and it's some kind of integer type
  c.getType().getUnderlyingType() instanceof IntegralType and
  not c.isFromTemplateInstantiation(_) and
  message =
    "Expression not converted to `unsigned char` before converting to a larger integer type."
}

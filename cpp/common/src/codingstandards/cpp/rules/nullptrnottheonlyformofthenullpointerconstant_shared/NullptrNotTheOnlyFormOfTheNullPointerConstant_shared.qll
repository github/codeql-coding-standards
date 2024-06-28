/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.commons.NULL

abstract class NullptrNotTheOnlyFormOfTheNullPointerConstant_sharedSharedQuery extends Query { }

Query getQuery() {
  result instanceof NullptrNotTheOnlyFormOfTheNullPointerConstant_sharedSharedQuery
}

query predicate problems(Literal l, string message) {
  not isExcluded(l, getQuery()) and // Not the type of the nullptr literal
  not l.getType() instanceof NullPointerType and
  // Converted to a pointer type
  l.getConversion().getType().getUnspecifiedType() instanceof PointerType and
  // Value of zero
  l.getValue() = "0" and
  // Not the StringLiteral "0"
  not l instanceof StringLiteral and
  message = l.getValueText() + " is used as the null-pointer-constant but is not nullptr."
}

/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Cpp14Literal

abstract class UnsignedIntegerLiteralsNotAppropriatelySuffixed_sharedSharedQuery extends Query { }

Query getQuery() {
  result instanceof UnsignedIntegerLiteralsNotAppropriatelySuffixed_sharedSharedQuery
}

query predicate problems(Cpp14Literal::NumericLiteral nl, string message) {
  exists(string literalKind |
    not isExcluded(nl, getQuery()) and
    (
      nl instanceof Cpp14Literal::OctalLiteral and literalKind = "Octal"
      or
      nl instanceof Cpp14Literal::HexLiteral and literalKind = "Hex"
    ) and
    // This either directly has an unsigned integer type, or it is converted to an unsigned integer type
    nl.getType().getUnspecifiedType().(IntegralType).isUnsigned() and
    // The literal already has a `u` or `U` suffix.
    not nl.getValueText().regexpMatch(".*[lL]*[uU][lL]*") and
    message = literalKind + " literal is an unsigned integer but does not include a 'U' suffix."
  )
}

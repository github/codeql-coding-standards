/**
 * Provides a library with a `problems` predicate for the following issue:
 * Octal constants shall not be used.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Cpp14Literal

abstract class UseOfNonZeroOctalLiteralSharedQuery extends Query { }

Query getQuery() { result instanceof UseOfNonZeroOctalLiteralSharedQuery }

query predicate problems(Cpp14Literal::OctalLiteral octalLiteral, string message) {
  not isExcluded(octalLiteral, getQuery()) and
  not octalLiteral.getValue() = "0" and
  message = "Non zero octal literal " + octalLiteral.getValueText() + "."
}

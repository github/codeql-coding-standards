/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Cpp14Literal

abstract class UseOfNonZeroOctalLiteral_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof UseOfNonZeroOctalLiteral_sharedSharedQuery }

query predicate problems(Cpp14Literal::OctalLiteral octalLiteral, string message) {
  not isExcluded(octalLiteral, getQuery()) and
  not octalLiteral.getValue() = "0" and
  message = "Non zero octal literal " + octalLiteral.getValueText() + "."
}

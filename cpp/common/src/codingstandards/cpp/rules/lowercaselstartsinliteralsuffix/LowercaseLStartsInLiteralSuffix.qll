/**
 * Provides a library with a `problems` predicate for the following issue:
 * The lowercase form of L shall not be used as the first character in a literal
 * suffix.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Literals

abstract class LowercaseLStartsInLiteralSuffixSharedQuery extends Query { }

Query getQuery() { result instanceof LowercaseLStartsInLiteralSuffixSharedQuery }

query predicate problems(IntegerLiteral l, string message) {
  not isExcluded(l, getQuery()) and
  exists(l.getValueText().indexOf("l")) and
  message = "Lowercase 'l' used as a literal suffix."
}

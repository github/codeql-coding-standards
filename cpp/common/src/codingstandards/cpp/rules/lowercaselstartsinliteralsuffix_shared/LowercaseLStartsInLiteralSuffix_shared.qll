/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Literals

abstract class LowercaseLStartsInLiteralSuffix_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof LowercaseLStartsInLiteralSuffix_sharedSharedQuery }

query predicate problems(IntegerLiteral l, string message) {
  not isExcluded(l, getQuery()) and
  exists(l.getValueText().indexOf("l")) and
  message = "Lowercase 'l' used as a literal suffix."
}

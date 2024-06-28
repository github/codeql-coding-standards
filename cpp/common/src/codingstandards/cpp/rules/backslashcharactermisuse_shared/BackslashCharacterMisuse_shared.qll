/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class BackslashCharacterMisuse_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof BackslashCharacterMisuse_sharedSharedQuery }

query predicate problems(StringLiteral l, string message) {
  exists(string es |
    not isExcluded(l, getQuery()) and
    es = l.getANonStandardEscapeSequence(_, _) and
    // Exclude universal-character-names, which begin with \u or \U
    not es.toLowerCase().matches("\\u") and
    message = "This literal contains the non-standard escape sequence " + es + "."
  )
}

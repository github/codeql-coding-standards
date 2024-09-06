/**
 * Provides a library with a `problems` predicate for the following issue:
 * In character literals and non-raw string literals, \ shall only be used to form a
 * defined escape sequence or universal character name.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class BackslashCharacterMisuseSharedQuery extends Query { }

Query getQuery() { result instanceof BackslashCharacterMisuseSharedQuery }

query predicate problems(StringLiteral l, string message) {
  exists(string es |
    not isExcluded(l, getQuery()) and
    es = l.getANonStandardEscapeSequence(_, _) and
    // Exclude universal-character-names, which begin with \u or \U
    not es.toLowerCase().matches("\\u") and
    message = "This literal contains the non-standard escape sequence " + es + "."
  )
}

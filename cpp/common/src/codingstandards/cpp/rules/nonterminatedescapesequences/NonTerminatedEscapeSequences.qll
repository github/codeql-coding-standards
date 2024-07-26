/**
 * Provides a library with a `problems` predicate for the following issue:
 * Octal escape sequences, hexadecimal escape sequences, and universal character names
 * shall be terminated.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class NonTerminatedEscapeSequencesSharedQuery extends Query { }

Query getQuery() { result instanceof NonTerminatedEscapeSequencesSharedQuery }

bindingset[s]
predicate isOctalEscape(string s) {
  s.charAt(0) = "\\" and
  exists(int i | i = [0 .. 7] | i.toString() = s.charAt(1))
}

bindingset[s]
predicate isHexEscape(string s) { s.indexOf("\\x") = 0 }

query predicate problems(Literal l, string message) {
  not isExcluded(l, getQuery()) and
  exists(int idx, string sl, string escapeKind, string s |
    sl = l.getValueText() and
    idx = sl.indexOf("\\") and
    s = sl.substring(idx, sl.length()) and
    // Note: Octal representations must be 1-3 digits. There is no limitation on a
    // Hex literal as long as the characters are valid. This query does not consider
    // if the hex literal being constructed will overflow.
    (
      isHexEscape(s) and
      not s.regexpMatch("^((\\\\x[0-9A-F]+(?=[\"'\\\\])))[\\s\\S]*") and
      escapeKind = "hexadecimal"
      or
      isOctalEscape(s) and
      not s.regexpMatch("^(((\\\\[0-7]{1,3})(?=[\"'\\\\])))[\\s\\S]*") and
      escapeKind = "octal"
    ) and
    message = "Invalid " + escapeKind + " escape in string literal at '" + s + "'."
  )
}

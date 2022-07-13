/**
 * @id c/misra/octal-and-hexadecimal-escape-sequences-not-terminated
 * @name RULE-4-1: Octal and hexadecimal escape sequences shall be terminated
 * @description Not explicitly terminating octal and hexadecimal escape sequences can results in
 *              developer confusion and lead to programming errors.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-4-1
 *       maintainability
 *       readability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

bindingset[s]
predicate isOctalEscape(string s) {
  s.charAt(0) = "\\" and
  exists(int i | i = [0 .. 7] | i.toString() = s.charAt(1))
}

bindingset[s]
predicate isHexEscape(string s) { s.indexOf("\\x") = 0 }

from Literal l, string escapeKind, string s
where
  not isExcluded(l, SyntaxPackage::octalAndHexadecimalEscapeSequencesNotTerminatedQuery()) and
  exists(int idx, string sl |
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
    )
  )
select l, "Invalid " + escapeKind + " escape in string literal at '" + s + "'."

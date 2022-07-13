/**
 * @id cpp/autosar/invalid-character-in-comment
 * @name A2-3-1: Use of characters outside the C++ Language Standard basic source character set
 * @description Only those characters specified in the C++ Language Standard basic source character
 *              set shall be used in a comment.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a2-3-1
 *       maintainability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

bindingset[s]
string getCharOutsideBasicSourceCharSet(string s) {
  result = s.regexpFind("[\\u0000-\\u007f]", _, _) and
  not result.regexpMatch("[\\p{Alnum}\\p{Space}_{}\\[\\]#()<>%:;.?*+-/^&|~!=,\\\\\"'@]")
  or
  result = s.regexpFind("[\\u00c0-\\u00df][\\u0080-\\u00bf]", _, _)
  or
  result = s.regexpFind("[\\u00e0-\\u00ef][\\u0080-\\u00bf]{2}", _, _)
  or
  result = s.regexpFind("[\\u00f0-\\u00f7][\\u0080-\\u00bf]{3}", _, _)
}

from Comment c, string ch
where
  not isExcluded(c, NamingPackage::invalidCharacterInCommentQuery()) and
  ch = getCharOutsideBasicSourceCharSet(c.getContents())
select c,
  "Comment uses the character '" + ch + "' that is outside the language basic character set."

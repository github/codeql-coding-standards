/**
 * @id cpp/autosar/invalid-character-in-string-literal
 * @name A2-3-1: Use of characters outside the C++ Language Standard basic source character set
 * @description Only those characters specified in the C++ Language Standard basic source character
 *              set shall be used in a string literal.
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
import codingstandards.cpp.Literals

bindingset[s]
string getCharOutsideBasicSourceCharSet(string s) {
  result = s.regexpFind("[\\u0000-\\uffff]", _, _) and
  not result.regexpMatch("[\\p{Alnum}\\p{Space}_{}\\[\\]#()<>%:;.?*+-/^&|~!=,\\\\\"'@]")
}

from StringLiteral s, string ch
where
  not isExcluded(s, NamingPackage::invalidCharacterInStringLiteralQuery()) and
  ch = getCharOutsideBasicSourceCharSet(s.getValueText()) and
  // wide string and utf8 string literals are exempted.
  not s instanceof WideStringLiteral and
  not s instanceof Utf8StringLiteral
select s,
  "String literal uses the character '" + ch + "' that is outside the language basic character set."

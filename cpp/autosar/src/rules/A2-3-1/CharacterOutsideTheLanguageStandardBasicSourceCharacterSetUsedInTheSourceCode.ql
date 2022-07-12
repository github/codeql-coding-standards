/**
 * @id cpp/autosar/character-outside-the-language-standard-basic-source-character-set-used-in-the-source-code
 * @name A2-3-1: Use of characters outside the C++ Language Standard basic source character set
 * @description Only those characters specified in the C++ Language Standard basic source character
 *              set shall be used in the source code.
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

// Any source-character not in the basic source character set is replaced by the universal-character-name
// according to [lex.phases]
string getUniversalCharacterName(Declaration d) {
  result = d.getName().regexpFind("(\\\\u\\p{XDigit}{4})|(\\\\U\\p{XDigit}{8})", _, _)
}

from Declaration d, string ch
where
  not isExcluded(d,
    NamingPackage::characterOutsideTheLanguageStandardBasicSourceCharacterSetUsedInTheSourceCodeQuery()) and
  ch = getUniversalCharacterName(d)
select d,
  "Declaration uses the character '" + ch + "' that is outside the language basic character set."

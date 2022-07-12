/**
 * @id cpp/autosar/universal-character-names-used-outside-character-or-string-literals
 * @name A2-13-6: Universal character names shall be used only inside character or string literals
 * @description Universal character names can be confusing to the developer, and may break tools
 *              which parse or process the source code.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a2-13-6
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

bindingset[s]
string getAUniversalCharacterName(string s) {
  result = s.regexpFind("(\\\\u\\p{XDigit}{4})|(\\\\U\\p{XDigit}{8})", _, _)
}

from Element e, string type, string name, string ch
where
  not isExcluded(e,
    NamingPackage::universalCharacterNamesUsedOutsideCharacterOrStringLiteralsQuery()) and
  ch = getAUniversalCharacterName(name) and
  (
    e instanceof DeclarationEntry and type = "Declaration" and name = e.(DeclarationEntry).getName()
    or
    e instanceof Namespace and type = "Namespace" and name = e.(Namespace).getName()
  )
select e,
  type + " uses the universal character name '" + ch +
    "' which should only be used inside character or string literals."

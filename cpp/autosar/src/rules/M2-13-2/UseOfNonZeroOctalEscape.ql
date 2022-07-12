/**
 * @id cpp/autosar/use-of-non-zero-octal-escape
 * @name M2-13-2: Octal escape sequences (other than '\0') shall not be used
 * @description Use of octal escape sequences (other than '\0') can lead to confusion with decimal
 *              numbers.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m2-13-2
 *       readability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Cpp14Literal

from TextLiteral textLiteral, string octalEscape
where
  not isExcluded(textLiteral, LiteralsPackage::useOfNonZeroOctalEscapeQuery()) and
  octalEscape = textLiteral.getAnOctalEscapeSequence(_, _) and
  not octalEscape = "\\0"
select textLiteral, "This literal contains the non-zero octal escape code " + octalEscape + "."

/**
 * @id cpp/autosar/use-of-non-zero-octal-literal
 * @name M2-13-2: Octal constants (other than zero) shall not be used
 * @description Use of octal constants (other than zero) can lead to confusion with decimal numbers.
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

from Cpp14Literal::OctalLiteral octalLiteral
where
  not isExcluded(octalLiteral, LiteralsPackage::useOfNonZeroOctalLiteralQuery()) and
  not octalLiteral.getValue() = "0"
select octalLiteral, "Non zero octal literal " + octalLiteral.getValueText() + "."

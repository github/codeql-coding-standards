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
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.useofnonzerooctalliteral.UseOfNonZeroOctalLiteral

class UseOfNonZeroOctalLiteralQuery extends UseOfNonZeroOctalLiteralSharedQuery {
  UseOfNonZeroOctalLiteralQuery() { this = LiteralsPackage::useOfNonZeroOctalLiteralQuery() }
}

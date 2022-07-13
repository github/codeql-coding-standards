/**
 * @id cpp/autosar/missing-u-suffix
 * @name M2-13-3: A 'U' suffix shall be applied to all octal or hexadecimal integer literals of unsigned type
 * @description Use a 'U' suffix to ensure all unsigned literals have a consistent signedness across
 *              platforms and compilers.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m2-13-3
 *       correctness
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

from Cpp14Literal::NumericLiteral nl, string literalKind
where
  not isExcluded(nl, LiteralsPackage::missingUSuffixQuery()) and
  (
    nl instanceof Cpp14Literal::OctalLiteral and literalKind = "Octal"
    or
    nl instanceof Cpp14Literal::HexLiteral and literalKind = "Hex"
  ) and
  // This either directly has an unsigned integer type, or it is converted to an unsigned integer type
  nl.getType().getUnspecifiedType().(IntegralType).isUnsigned() and
  // The literal already has a `u` or `U` suffix.
  not nl.getValueText().regexpMatch(".*[lL]*[uU][lL]*")
select nl, literalKind + " literal is an unsigned integer but does not include a 'U' suffix."

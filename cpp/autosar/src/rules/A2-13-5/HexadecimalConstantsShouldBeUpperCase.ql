/**
 * @id cpp/autosar/hexadecimal-constants-should-be-upper-case
 * @name A2-13-5: Hexadecimal constants should be upper case
 * @description Using a mix of lower and upper case hexadecimal constants is inconsistent and
 *              confusing.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a2-13-5
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Cpp14Literal

from Cpp14Literal::HexLiteral hl
where
  not isExcluded(hl, LiteralsPackage::hexadecimalConstantsShouldBeUpperCaseQuery()) and
  // Take the suffix to remove the 0x prefix, then find lowercase characters
  exists(hl.getValueText().suffix(2).regexpFind("[a-f]", _, _))
select hl, "The hexidecimal constant " + hl.getValueText() + " contains lower case literals."

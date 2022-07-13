/**
 * @id cpp/autosar/literal-suffix-not-upper-case
 * @name M2-13-4: Literal suffixes shall be upper case
 * @description An upper case literal suffix avoids ambiguity between the letter 'l' and the digit
 *              '1'.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m2-13-4
 *       readability
 *       correctness
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Cpp14Literal

from Cpp14Literal::NumericLiteral nl, string suffix, string regex
where
  not isExcluded(nl, LiteralsPackage::literalSuffixNotUpperCaseQuery()) and
  (
    if nl instanceof Cpp14Literal::FloatingLiteral
    then regex = "^.*([lf])$"
    else regex = "^.*[0-9a-fA-F][UL]*([ul]+)[UL]*$"
  ) and
  suffix = nl.getValueText().regexpCapture(regex, 1)
select nl, "Numeric literal " + nl.getValueText() + " has the lower case suffix " + suffix + "."

/**
 * @id cpp/autosar/use-correct-interval-for-digit-sequences-separators
 * @name A13-6-1: Digit sequence separators should only be used at the proscribed intervals
 * @description Digit sequences separators ' shall only be used as follows: (1) for decimal, every 3
 *              digits, (2) for hexadecimal, every 2 digits, (3) for binary, every 4 digits.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a13-6-1
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Cpp14Literal

int getDigitSequenceSeparatorSpacing(Literal l) {
  result = 3 and
  (l instanceof Cpp14Literal::FloatingLiteral or l instanceof Cpp14Literal::DecimalLiteral)
  or
  result = 2 and l instanceof Cpp14Literal::HexLiteral
  or
  result = 4 and l instanceof Cpp14Literal::BinaryLiteral
}

string getADigitSequence(Literal l) {
  result = l.getValueText().regexpFind("[0-9']+", _, _) and
  (l instanceof Cpp14Literal::FloatingLiteral or l instanceof Cpp14Literal::DecimalLiteral)
  or
  result = l.getValueText().suffix(2).regexpFind("[0-9A-Fa-f']+", _, _) and
  (l instanceof Cpp14Literal::HexLiteral or l instanceof Cpp14Literal::BinaryLiteral)
}

from Cpp14Literal::NumericLiteral l, string digitSequence, int spacing
where
  not isExcluded(l, LiteralsPackage::useCorrectIntervalForDigitSequencesSeparatorsQuery()) and
  digitSequence = getADigitSequence(l) and
  spacing = getDigitSequenceSeparatorSpacing(l) and
  (
    not digitSequence.regexpMatch("[0-9A-Fa-f]{1," + spacing + "}('[0-9A-Fa-f]{" + spacing + "})*") and
    not digitSequence.regexpMatch("[0-9A-Fa-f]+")
  )
select l,
  "The digit sequence " + digitSequence +
    " uses a digit sequence separator at a spacing other than " + spacing + "."

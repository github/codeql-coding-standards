/**
 * @id c/cert/use-correct-integer-precisions
 * @name INT35-C: Use correct integer precisions
 * @description The precision of integer types in C cannot be deduced from the size of the type (due
 *              to padding and sign bits) otherwise a loss of data may occur.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/int35-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

class CharBitMacroInvocation extends MacroInvocation {
  CharBitMacroInvocation() { this.getMacroName() = "CHAR_BIT" }
}

from SizeofOperator so, RelationalOperation comparison, MulExpr m, Expr charSize
where
  not isExcluded(so, IntegerOverflowPackage::useCorrectIntegerPrecisionsQuery()) and
  // Multiplication of a sizeof operator and a constant that's probably a char size
  m.getAnOperand() = so and
  m.getAnOperand() = charSize and
  not so = charSize and
  (
    charSize.getValue().toInt() = 8
    or
    charSize = any(CharBitMacroInvocation c).getExpr()
  ) and
  // The result is compared against something, which is probably related to the number of bits
  comparison.getAnOperand() = m
select so, "sizeof operator used to determine the precision of an integer type."

/**
 * Provides a configurable module DivisorEqualToZeroShared with a `problems` predicate
 * for the following issue:
 * The result is undefined if the right hand operand of the integer division or the
 * remainder operator is zero.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

signature module DivisorEqualToZeroSharedConfigSig {
  Query getQuery();
}

module DivisorEqualToZeroShared<DivisorEqualToZeroSharedConfigSig Config> {
  query predicate problems(BinaryArithmeticOperation bao, string message) {
    not isExcluded(bao, Config::getQuery()) and
    (bao instanceof DivExpr or bao instanceof RemExpr) and
    bao.getRightOperand().getValue().toFloat() = 0 and // `toFloat()` holds for both integer and float literals.
    message = "Divisor is zero."
  }
}

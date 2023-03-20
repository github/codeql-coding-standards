/**
 * @id c/misra/constant-unsigned-integer-expressions-wrap-around
 * @name RULE-12-4: Evaluation of constant expressions should not lead to unsigned integer wrap-around
 * @description Unsigned integer expressions do not strictly overflow, but instead wrap around in a
 *              modular way. Any constant unsigned integer expressions that in effect "overflow"
 *              will not be detected by the compiler. Although there may be good reasons at run-time
 *              to rely on the modular arithmetic provided by unsigned integer types, the reasons
 *              for using it at compile-time to evaluate a constant expression are less obvious. Any
 *              instance of an unsigned integer constant expression wrapping around is therefore
 *              likely to indicate a programming error.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-4
 *       correctness
 *       security
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.constantunsignedintegerexpressionswraparound.ConstantUnsignedIntegerExpressionsWrapAround

class ConstantUnsignedIntegerExpressionsWrapAroundQuery extends ConstantUnsignedIntegerExpressionsWrapAroundSharedQuery {
  ConstantUnsignedIntegerExpressionsWrapAroundQuery() {
    this = IntegerOverflowPackage::constantUnsignedIntegerExpressionsWrapAroundQuery()
  }
}

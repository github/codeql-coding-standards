/**
 * @id cpp/autosar/constant-unsigned-integer-expressions-wrap-around
 * @name M5-19-1: Evaluation of constant unsigned integer expressions shall not lead to wrap-around
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
 * @tags external/autosar/id/m5-19-1
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.constantunsignedintegerexpressionswraparound.ConstantUnsignedIntegerExpressionsWrapAround

class ConstantUnsignedIntegerExpressionsWrapAroundQuery extends ConstantUnsignedIntegerExpressionsWrapAroundSharedQuery {
  ConstantUnsignedIntegerExpressionsWrapAroundQuery() {
    this = ExpressionsPackage::constantUnsignedIntegerExpressionsWrapAroundQuery()
  }
}

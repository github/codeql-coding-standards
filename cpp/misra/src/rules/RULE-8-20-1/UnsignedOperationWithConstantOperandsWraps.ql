/**
 * @id cpp/misra/unsigned-operation-with-constant-operands-wraps
 * @name RULE-8-20-1: An unsigned arithmetic operation with constant operands should not wrap
 * @description An unsigned arithmetic operation with constant operands should not wrap.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-20-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.unsignedoperationwithconstantoperandswraps_shared.UnsignedOperationWithConstantOperandsWraps_shared

class UnsignedOperationWithConstantOperandsWrapsQuery extends UnsignedOperationWithConstantOperandsWraps_sharedSharedQuery {
  UnsignedOperationWithConstantOperandsWrapsQuery() {
    this = ImportMisra23Package::unsignedOperationWithConstantOperandsWrapsQuery()
  }
}

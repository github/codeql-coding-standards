/**
 * @id c/cert/do-not-add-or-subtract-a-scaled-integer-to-a-pointer
 * @name ARR39-C: Do not add or subtract a scaled integer to a pointer
 * @description Adding or subtracting a scaled integer value to or from a pointer may yield an
 *              out-of-bounds pointer.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/arr39-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Pointers
import semmle.code.cpp.dataflow.TaintTracking
import DataFlow::PathGraph

/**
 * An expression which invokes the `offsetof` macro or `__builtin_offsetof` operation.
 */
class OffsetOfExpr extends Expr {
  OffsetOfExpr() {
    this instanceof BuiltInOperationBuiltInOffsetOf
    or
    exists(MacroInvocation mi | mi.getMacroName() = "offsetof" and mi.getExpr() = this)
  }
}

/**
 * An array expression conforming to the `arr[sizeof(arr)/sizeof(arr[0])]` idiom.
 */
class ArrayCountOfExpr extends ArrayExpr {
  ArrayCountOfExpr() {
    exists(DivExpr div, Variable arr, VariableAccess left, ArrayExpr right |
      div = this.getArrayOffset() and
      arr = this.getArrayBase().(VariableAccess).getTarget() and
      // exclude cases where arr is a pointer rather than an array
      arr.getUnderlyingType() instanceof ArrayType and
      // holds if the dividend is sizeof(arr)
      left = div.getLeftOperand().(SizeofExprOperator).getExprOperand() and
      left.getTarget() = this.getArrayBase().(VariableAccess).getTarget() and
      // holds if the divisor is sizeof(arr[0])
      right = div.getRightOperand().(SizeofExprOperator).getExprOperand() and
      right.getArrayBase().(VariableAccess).getTarget() = arr and
      right.getArrayOffset().(Literal).getValue() = "0"
    )
  }
}

/**
 * An `offsetof` expression or a `sizeof` expression with an operand of a size greater than 1.
 */
class ScaledIntegerExpr extends Expr {
  ScaledIntegerExpr() {
    not this.getParent*() instanceof ArrayCountOfExpr and
    (
      this.(SizeofExprOperator).getExprOperand().getType().getSize() > 1
      or
      this.(SizeofTypeOperator).getTypeOperand().getSize() > 1
      or
      this instanceof OffsetOfExpr
    )
  }
}

/**
 * A data-flow configuration modeling data-flow from a `ScaledIntegerExpr` to a
 * `PointerArithmeticExpr` where the pointer does not point to a 1-byte type.
 */
class ScaledIntegerPointerArithmeticConfig extends DataFlow::Configuration {
  ScaledIntegerPointerArithmeticConfig() { this = "ScaledIntegerPointerArithmeticConfig" }

  override predicate isSource(DataFlow::Node src) { src.asExpr() instanceof ScaledIntegerExpr }

  override predicate isSink(DataFlow::Node sink) {
    exists(PointerArithmeticExpr pa |
      // exclude pointers to 1-byte types as they do not scale
      pa.getPointer().getFullyConverted().getType().(DerivedType).getBaseType().getSize() != 1 and
      pa.getOperand().getAChild*() = sink.asExpr()
    )
  }
}

from ScaledIntegerPointerArithmeticConfig config, DataFlow::PathNode src, DataFlow::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    Pointers2Package::doNotAddOrSubtractAScaledIntegerToAPointerQuery()) and
  config.hasFlowPath(src, sink)
select sink, src, sink, "Scaled integer used in pointer arithmetic."

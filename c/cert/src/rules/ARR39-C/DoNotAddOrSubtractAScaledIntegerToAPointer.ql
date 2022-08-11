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
import semmle.code.cpp.dataflow.TaintTracking
import DataFlow::PathGraph

/**
 * An expression which performs pointer arithmetic
 */
abstract class PointerArithmeticExpr extends Expr {
  abstract Expr getPointer();

  abstract Expr getOperand();
}

class SimplePointerArithmeticExpr extends PointerArithmeticExpr, PointerArithmeticOperation {
  override Expr getPointer() { result = this.getLeftOperand() }

  override Expr getOperand() { result = this.getRightOperand() }
}

class AssignPointerArithmeticExpr extends PointerArithmeticExpr, AssignOperation {
  AssignPointerArithmeticExpr() {
    this instanceof AssignPointerAddExpr or
    this instanceof AssignPointerSubExpr
  }

  override Expr getPointer() { result = this.getLValue() }

  override Expr getOperand() { result = this.getRValue() }
}

class ArrayPointerArithmeticExpr extends PointerArithmeticExpr, ArrayExpr {
  override Expr getPointer() { result = this.getArrayBase() }

  override Expr getOperand() { result = this.getArrayOffset() }
}

class OffsetOfExpr extends Expr {
  OffsetOfExpr() {
    this instanceof BuiltInOperationBuiltInOffsetOf
    or
    exists(MacroInvocation mi | mi.getMacroName() = "offsetof" and mi.getExpr() = this)
  }
}

/**
 * An array expression conforming to the "arr[ sizeof(arr)/sizeof(arr[ 0 ]) ]" idiom
 */
class ArrayCountOfExpr extends ArrayExpr {
  ArrayCountOfExpr() {
    exists(DivExpr div, Variable arr, VariableAccess left, ArrayExpr right |
      div = this.getArrayOffset() and
      arr = this.getArrayBase().(VariableAccess).getTarget() and
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

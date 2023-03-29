/**
 * @id c/cert/do-not-use-pointer-arithmetic-on-non-array-object-pointers
 * @name ARR37-C: Do not add or subtract an integer to a pointer to a non-array object
 * @description A pair of elements that are not elements in the same array are not guaranteed to be
 *              contiguous in memory and therefore should not be addressed using pointer arithmetic.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/arr37-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

/**
 * A data-flow configuration that tracks flow from an `AddressOfExpr` of a variable
 * of `PointerType` that is not also an `ArrayType` to a `PointerArithmeticOrArrayExpr`
 */
class NonArrayPointerToArrayIndexingExprConfig extends DataFlow::Configuration {
  NonArrayPointerToArrayIndexingExprConfig() { this = "ArrayToArrayIndexConfig" }

  override predicate isSource(DataFlow::Node source) {
    exists(AddressOfExpr ao, Type t |
      source.asExpr() = ao and
      not ao.getOperand() instanceof ArrayExpr and
      not ao.getOperand() instanceof PointerDereferenceExpr and
      t = ao.getOperand().getType() and
      not t instanceof PointerType and
      not t instanceof ArrayType and
      not t.(PointerType).getBaseType() instanceof ArrayType
    )
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(PointerArithmeticOrArrayExpr ae |
      sink.asExpr() = ae.getPointerOperand() and
      not sink.asExpr() instanceof Literal and
      not ae.isNonPointerOperandZero()
    )
  }

  override predicate isBarrierOut(DataFlow::Node node) {
    // the default interprocedural data-flow model flows through any field or array assignment
    // expressions to the qualifier (array base, pointer dereferenced, or qualifier) instead of the
    // individual element or field that the assignment modifies. this default behaviour causes
    // false positives for future accesses of any element of that object, so we remove the edges
    // between those assignments from the graph with `isBarrierOut`.
    exists(AssignExpr a |
      node.asExpr() = a.getRValue() and
      (
        a.getLValue() instanceof ArrayExpr or
        a.getLValue() instanceof PointerDereferenceExpr or
        a.getLValue() instanceof FieldAccess
      )
    )
    or
    // ignore AddressOfExpr output e.g. call(&s1)
    node.asDefiningArgument() instanceof AddressOfExpr
  }
}

class PointerArithmeticOrArrayExpr extends Expr {
  Expr operand;

  PointerArithmeticOrArrayExpr() {
    operand = this.(ArrayExpr).getArrayBase()
    or
    operand = this.(ArrayExpr).getArrayOffset()
    or
    operand = this.(PointerAddExpr).getAnOperand()
    or
    operand = this.(PointerSubExpr).getAnOperand()
    or
    operand = this.(Operation).getAnOperand() and
    operand.getUnderlyingType() instanceof PointerType and
    (
      this instanceof PostfixCrementOperation
      or
      this instanceof PrefixIncrExpr
      or
      this instanceof PrefixDecrExpr
    )
  }

  /**
   * Gets the operands of this expression. If the expression is an
   * `ArrayExpr`, the results are the array base and offset `Expr`s.
   */
  Expr getPointerOperand() {
    result = operand or
    result = this.(PointerArithmeticOrArrayExpr).getPointerOperand()
  }

  /**
   * Holds if there exists an operand that is a `Literal` with a value of `0`.
   */
  predicate isNonPointerOperandZero() { operand.(Literal).getValue().toInt() = 0 }
}

from DataFlow::PathNode source, DataFlow::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    InvalidMemory2Package::doNotUsePointerArithmeticOnNonArrayObjectPointersQuery()) and
  any(NonArrayPointerToArrayIndexingExprConfig cfg).hasFlowPath(source, sink)
select sink, source, sink, "Pointer arithmetic on non-array object pointer."

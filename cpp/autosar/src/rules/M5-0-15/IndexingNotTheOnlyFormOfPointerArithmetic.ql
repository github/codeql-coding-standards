/**
 * @id cpp/autosar/indexing-not-the-only-form-of-pointer-arithmetic
 * @name M5-0-15: Array indexing shall be the only form of pointer arithmetic
 * @description Array indexing shall be the only form of pointer arithmetic because it less error
 *              prone than pointer manipulation.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/m5-0-15
 *       correctness
 *       external/autosar/strict
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow

class ArrayToArrayBaseConfig extends DataFlow::Configuration {
  ArrayToArrayBaseConfig() { this = "ArrayToArrayBaseConfig" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr().(VariableAccess).getType() instanceof ArrayType
    or
    // Consider array to pointer decay for parameters.
    source.asExpr().(VariableAccess).getTarget().(Parameter).getType() instanceof ArrayType
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(ArrayExpr e | e.getArrayBase() = sink.asExpr())
  }
}

predicate hasPointerResult(PointerArithmeticOperation op) {
  op instanceof PointerAddExpr
  or
  op instanceof PointerSubExpr
}

predicate shouldBeArray(ArrayExpr arrayExpr) {
  arrayExpr.getArrayBase().getUnspecifiedType() instanceof PointerType and
  not exists(VariableAccess va |
    any(ArrayToArrayBaseConfig config)
        .hasFlow(DataFlow::exprNode(va), DataFlow::exprNode(arrayExpr.getArrayBase()))
  ) and
  not exists(Variable v |
    v.getAnAssignedValue().getType() instanceof ArrayType and
    arrayExpr.getArrayBase() = v.getAnAccess()
  )
}

from Expr e
where
  not isExcluded(e, PointersPackage::indexingNotTheOnlyFormOfPointerArithmeticQuery()) and
  (
    hasPointerResult(e)
    or
    shouldBeArray(e)
  ) and
  not e.isAffectedByMacro()
select e,
  "Use of pointer arithmetic other than array indexing or indexing pointer not declared as an array."

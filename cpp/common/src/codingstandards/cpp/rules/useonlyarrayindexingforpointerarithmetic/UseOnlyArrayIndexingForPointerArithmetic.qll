/**
 * Provides a library which includes a `problems` predicate for reporting
 * instances of pointer arithmetic using means other than array indexing.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow

abstract class UseOnlyArrayIndexingForPointerArithmeticSharedQuery extends Query { }

module ArrayToArrayBaseConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr().(VariableAccess).getType() instanceof ArrayType
    or
    // Consider array to pointer decay for parameters.
    source.asExpr().(VariableAccess).getTarget().(Parameter).getType() instanceof ArrayType
  }

  predicate isSink(DataFlow::Node sink) { exists(ArrayExpr e | e.getArrayBase() = sink.asExpr()) }
}

module ArrayToArrayBaseFlow = DataFlow::Global<ArrayToArrayBaseConfig>;

predicate hasPointerResult(PointerArithmeticOperation op) {
  op instanceof PointerAddExpr
  or
  op instanceof PointerSubExpr
}

predicate shouldBeArray(ArrayExpr arrayExpr) {
  arrayExpr.getArrayBase().getUnspecifiedType() instanceof PointerType and
  not exists(VariableAccess va |
    ArrayToArrayBaseFlow::flow(DataFlow::exprNode(va), DataFlow::exprNode(arrayExpr.getArrayBase()))
  ) and
  not exists(Variable v |
    v.getAnAssignedValue().getType() instanceof ArrayType and
    arrayExpr.getArrayBase() = v.getAnAccess()
  )
}

Query getQuery() { result instanceof UseOnlyArrayIndexingForPointerArithmeticSharedQuery }

query predicate problems(Expr e, string message) {
  not isExcluded(e, getQuery()) and
  (
    hasPointerResult(e)
    or
    shouldBeArray(e)
  ) and
  not e.isAffectedByMacro() and
  message =
    "Use of pointer arithmetic other than array indexing or indexing pointer not declared as an array."
}

/**
 * @id c/cert/do-not-modify-constant-objects
 * @name EXP40-C: Do not modify constant objects
 * @description Do not modify constant objects. This may result in undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp40-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph
import codingstandards.cpp.SideEffect

class ConstRemovingCast extends Cast {
  ConstRemovingCast() {
    this.getExpr().getType().(DerivedType).getBaseType*().isConst() and
    not this.getType().(DerivedType).getBaseType*().isConst()
  }
}

class MaybeReturnsStringLiteralFunctionCall extends FunctionCall {
  MaybeReturnsStringLiteralFunctionCall() {
    getTarget().getName() in [
        "strpbrk", "strchr", "strrchr", "strstr", "wcspbrk", "wcschr", "wcsrchr", "wcsstr",
        "memchr", "wmemchr"
      ]
  }
}

class MyDataFlowConfCast extends DataFlow::Configuration {
  MyDataFlowConfCast() { this = "MyDataFlowConfCast" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr().getFullyConverted() instanceof ConstRemovingCast
    or
    source.asExpr().getFullyConverted() = any(MaybeReturnsStringLiteralFunctionCall c)
  }

  override predicate isSink(DataFlow::Node sink) {
    sink.asExpr() = any(Assignment a).getLValue().(PointerDereferenceExpr).getOperand()
  }
}

from MyDataFlowConfCast conf, DataFlow::PathNode src, DataFlow::PathNode sink
where
  conf.hasFlowPath(src, sink)
  or
  sink.getNode()
      .asExpr()
      .(VariableEffect)
      .getTarget()
      .getType()
      .(DerivedType)
      .getBaseType*()
      .isConst()
select sink, src, sink, "Const variable assigned with non const-value."

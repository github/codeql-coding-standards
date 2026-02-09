/**
 * @id c/cert/do-not-modify-constant-objects
 * @name EXP40-C: Do not modify constant objects
 * @description Do not modify constant objects. This may result in undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp40-c
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow
import CastFlow::PathGraph
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

module CastConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr().getFullyConverted() instanceof ConstRemovingCast
    or
    source.asExpr().getFullyConverted() = any(MaybeReturnsStringLiteralFunctionCall c)
  }

  predicate isSink(DataFlow::Node sink) {
    sink.asExpr() = any(Assignment a).getLValue().(PointerDereferenceExpr).getOperand()
  }
}

module CastFlow = DataFlow::Global<CastConfig>;

from CastFlow::PathNode src, CastFlow::PathNode sink
where
  CastFlow::flowPath(src, sink)
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

/**
 * @id c/cert/do-not-call-function-pointer-with-incompatible-type
 * @name EXP37-C: Do not call a function pointer which points to a function of an incompatible type
 * @description Calling a function pointer with a type incompatible with the function it points to
 *              is undefined.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp37-c
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow
import SuspectFunctionPointerToCallFlow::PathGraph

/**
 * An expression of type `FunctionPointer` which is the unconverted expression of a cast
 * which converts the function pointer to a pointer to a function of a different type.
 */
class SuspiciousFunctionPointerCastExpr extends Expr {
  SuspiciousFunctionPointerCastExpr() {
    exists(CStyleCast cast, Type old, Type new |
      this = cast.getUnconverted() and
      old = cast.getUnconverted().getUnderlyingType() and
      new = cast.getFullyConverted().getUnderlyingType() and
      old != new and
      old instanceof FunctionPointerType and
      new instanceof FunctionPointerType
    )
  }
}

/**
 * Data-flow configuration for flow from a `SuspiciousFunctionPointerCastExpr`
 * to a call of the function pointer resulting from the function pointer cast
 */
module SuspectFunctionPointerToCallConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node src) {
    src.asExpr() instanceof SuspiciousFunctionPointerCastExpr
  }

  predicate isSink(DataFlow::Node sink) {
    exists(VariableCall call | sink.asExpr() = call.getExpr().(VariableAccess))
  }
}

module SuspectFunctionPointerToCallFlow = DataFlow::Global<SuspectFunctionPointerToCallConfig>;

from
  SuspectFunctionPointerToCallFlow::PathNode src, SuspectFunctionPointerToCallFlow::PathNode sink,
  Access access
where
  not isExcluded(src.getNode().asExpr(),
    ExpressionsPackage::doNotCallFunctionPointerWithIncompatibleTypeQuery()) and
  access = src.getNode().asExpr() and
  SuspectFunctionPointerToCallFlow::flowPath(src, sink)
select src, src, sink,
  "Incompatible function $@ assigned to function pointer is eventually called through the pointer.",
  access.getTarget(), access.getTarget().getName()

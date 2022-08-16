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
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

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
class SuspectFunctionPointerToCallConfig extends DataFlow::Configuration {
  SuspectFunctionPointerToCallConfig() { this = "SuspectFunctionPointerToCallConfig" }

  override predicate isSource(DataFlow::Node src) {
    src.asExpr() instanceof SuspiciousFunctionPointerCastExpr
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(VariableCall call | sink.asExpr() = call.getExpr().(VariableAccess))
  }
}

from
  SuspectFunctionPointerToCallConfig config, DataFlow::PathNode src, DataFlow::PathNode sink,
  Access access
where
  not isExcluded(src.getNode().asExpr(),
    ExpressionsPackage::doNotCallFunctionPointerWithIncompatibleTypeQuery()) and
  access = src.getNode().asExpr() and
  config.hasFlowPath(src, sink)
select src, src, sink,
  "Incompatible function $@ assigned to function pointer is eventually called through the pointer.",
  access.getTarget(), access.getTarget().getName()

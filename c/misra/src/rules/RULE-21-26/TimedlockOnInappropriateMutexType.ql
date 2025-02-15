/**
 * @id c/misra/timedlock-on-inappropriate-mutex-type
 * @name RULE-21-26: The Standard Library function mtx_timedlock() shall only be invoked on mutexes of type mtx_timed
 * @description The Standard Library function mtx_timedlock() shall only be invoked on mutex objects
 *              of appropriate mutex type.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-21-26
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.dataflow.new.DataFlow

class MutexTimed extends EnumConstant {
  MutexTimed() { hasName("mtx_timed") }
}

class MutexInitCall extends FunctionCall {
  Expr mutexExpr;
  Expr mutexTypeExpr;

  MutexInitCall() {
    getTarget().hasName("mtx_init") and
    mutexExpr = getArgument(0) and
    mutexTypeExpr = getArgument(1)
  }

  predicate isTimedMutexType() {
    exists(EnumConstantAccess baseTypeAccess |
      (
        baseTypeAccess = mutexTypeExpr
        or
        baseTypeAccess = mutexTypeExpr.(BinaryBitwiseOperation).getAnOperand()
      ) and
      baseTypeAccess.getTarget() instanceof MutexTimed
    )
    or
    mutexTypeExpr.getValue().toInt() = any(MutexTimed m).getValue().toInt()
  }

  Expr getMutexExpr() { result = mutexExpr }
}

module MutexTimedlockFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    exists(MutexInitCall init |
      node.asDefiningArgument() = init.getMutexExpr() and not init.isTimedMutexType()
    )
  }

  predicate isSink(DataFlow::Node node) {
    exists(FunctionCall fc |
      fc.getTarget().hasName("mtx_timedlock") and
      node.asIndirectExpr() = fc.getArgument(0)
    )
  }
}

module Flow = DataFlow::Global<MutexTimedlockFlowConfig>;

import Flow::PathGraph

from Flow::PathNode source, Flow::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    Concurrency7Package::timedlockOnInappropriateMutexTypeQuery()) and
  Flow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "Call to mtx_timedlock with mutex which is $@ without flag 'mtx_timed'.", source.getNode(),
  "initialized"

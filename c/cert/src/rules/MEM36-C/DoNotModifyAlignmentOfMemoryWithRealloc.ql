/**
 * @id c/cert/do-not-modify-alignment-of-memory-with-realloc
 * @name MEM36-C: Do not modify the alignment of objects by calling realloc
 * @description Realloc does not preserve the alignment of memory allocated with aligned_alloc and
 *              can result in undefined behavior if reallocating more strictly aligned memory.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/mem36-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Alignment
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

int getStatedValue(Expr e) {
  // `upperBound(e)` defaults to `exprMaxVal(e)` when `e` isn't analyzable. So to get a meaningful
  // result in this case we pick the minimum value obtainable from dataflow and range analysis.
  result =
    upperBound(e)
        .minimum(min(Expr source | DataFlow::localExprFlow(source, e) | source.getValue().toInt()))
}

class NonDefaultAlignedAllocCall extends FunctionCall {
  NonDefaultAlignedAllocCall() {
    this.getTarget().hasName("aligned_alloc") and
    not getStatedValue(this.getArgument(0)) = getGlobalMaxAlignT()
  }
}

class ReallocCall extends FunctionCall {
  ReallocCall() { this.getTarget().hasName("realloc") }
}

class AlignedAllocToReallocConfig extends DataFlow::Configuration {
  AlignedAllocToReallocConfig() { this = "AlignedAllocToReallocConfig" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof NonDefaultAlignedAllocCall
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(ReallocCall realloc | sink.asExpr() = realloc.getArgument(0))
  }
}

from AlignedAllocToReallocConfig cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    Memory2Package::doNotModifyAlignmentOfMemoryWithReallocQuery()) and
  cfg.hasFlowPath(source, sink)
select sink, source, sink, "Memory allocated with $@ but reallocated with realloc.",
  source.getNode().asExpr(), "aligned_alloc"

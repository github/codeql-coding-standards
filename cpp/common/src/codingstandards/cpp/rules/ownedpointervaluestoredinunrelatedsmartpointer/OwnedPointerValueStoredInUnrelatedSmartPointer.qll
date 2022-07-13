/**
 * Provides a library which includes a `problems` predicate for reporting instances of identical
 * pointer values flowing into multiple unrelated smart pointer objects,
 * thus leading to lifetime issues.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.SmartPointers
import semmle.code.cpp.dataflow.TaintTracking
import DataFlow::PathGraph

abstract class OwnedPointerValueStoredInUnrelatedSmartPointerSharedQuery extends Query { }

Query getQuery() { result instanceof OwnedPointerValueStoredInUnrelatedSmartPointerSharedQuery }

private class PointerToSmartPointerConstructorFlowConfig extends TaintTracking::Configuration {
  PointerToSmartPointerConstructorFlowConfig() { this = "PointerToSmartPointerConstructorFlow" }

  override predicate isSource(DataFlow::Node source) {
    exists(Variable v | v.getAnAssignedValue() = source.asExpr())
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(AutosarSmartPointer sp, ConstructorCall cc |
      sp.getAConstructorCall() = cc and
      cc.getArgument(0).getFullyConverted().getType() instanceof PointerType and
      cc.getArgument(0) = sink.asExpr()
    )
  }
}

query predicate problems(
  DataFlow::Node sinkNode, DataFlow::PathNode source, DataFlow::PathNode sink, string message
) {
  not isExcluded(sinkNode.asExpr(), getQuery()) and
  exists(PointerToSmartPointerConstructorFlowConfig config, DataFlow::PathNode sink2 |
    sink != sink2 and
    sinkNode = sink.getNode() and
    config.hasFlowPath(source, sink) and
    config.hasFlowPath(source, sink2) and
    message = "Raw pointer flows to initialize multiple unrelated smart pointers."
  )
}

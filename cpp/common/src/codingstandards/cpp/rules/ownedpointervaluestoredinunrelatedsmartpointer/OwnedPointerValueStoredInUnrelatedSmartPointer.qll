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
import PointerToSmartPointerConstructorFlowFlow::PathGraph

abstract class OwnedPointerValueStoredInUnrelatedSmartPointerSharedQuery extends Query { }

Query getQuery() { result instanceof OwnedPointerValueStoredInUnrelatedSmartPointerSharedQuery }

private module PointerToSmartPointerConstructorFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(Variable v | v.getAnAssignedValue() = source.asExpr())
  }

  predicate isSink(DataFlow::Node sink) {
    exists(AutosarSmartPointer sp, ConstructorCall cc |
      sp.getAConstructorCall() = cc and
      cc.getArgument(0).getFullyConverted().getType() instanceof PointerType and
      cc.getArgument(0) = sink.asExpr()
    )
  }

  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    // Summarize flow through constructor calls
    exists(AutosarSmartPointer sp, ConstructorCall cc |
      sp.getAConstructorCall() = cc and
      cc = node2.asExpr() and
      cc.getArgument(0) = node1.asExpr()
    )
    or
    // Summarize flow through get() calls
    exists(AutosarSmartPointer sp, FunctionCall fc |
      sp.getAGetCall() = fc and
      fc = node2.asExpr() and
      fc.getQualifier() = node1.asExpr()
    )
  }

  predicate isBarrierIn(DataFlow::Node node) {
    // Exclude flow into header files outside the source archive which are summarized by the
    // additional taint steps above.
    exists(AutosarSmartPointer sp |
      sp.getAConstructorCall().getTarget().getAParameter() = node.asParameter()
      or
      sp.getAGetCall().getTarget().getAParameter() = node.asParameter()
    |
      not exists(node.getLocation().getFile().getRelativePath())
    )
  }
}

private module PointerToSmartPointerConstructorFlowFlow =
  TaintTracking::Global<PointerToSmartPointerConstructorFlowConfig>;

query predicate problems(
  DataFlow::Node sinkNode, PointerToSmartPointerConstructorFlowFlow::PathNode source,
  PointerToSmartPointerConstructorFlowFlow::PathNode sink, string message
) {
  not isExcluded(sinkNode.asExpr(), getQuery()) and
  exists(PointerToSmartPointerConstructorFlowFlow::PathNode sink2 |
    sink != sink2 and
    sinkNode = sink.getNode() and
    PointerToSmartPointerConstructorFlowFlow::flowPath(source, sink) and
    PointerToSmartPointerConstructorFlowFlow::flowPath(source, sink2) and
    message = "Raw pointer flows to initialize multiple unrelated smart pointers."
  )
}

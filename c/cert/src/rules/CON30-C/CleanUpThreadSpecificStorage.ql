/**
 * @id c/cert/clean-up-thread-specific-storage
 * @name CON30-C: Clean up thread-specific storage
 * @description Failing to clean up thread-specific resources can lead to unpredictable program
 *              behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/con30-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Concurrency
import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.dataflow.DataFlow

class FreeFunctionCall extends FunctionCall {
  FreeFunctionCall() { getTarget().getName() = "free" }
}

class TssCreateToTssDeleteDataFlowConfiguration extends DataFlow::Configuration {
  TssCreateToTssDeleteDataFlowConfiguration() { this = "TssCreateToTssDeleteDataFlowConfiguration" }

  override predicate isSource(DataFlow::Node node) {
    exists(TSSCreateFunctionCall tsc, Expr e |
      // the only requirement of the source is that at some point
      // it refers to the key of a create statement
      e.getParent*() = tsc.getKey() and
      (e = node.asDefiningArgument() or e = node.asExpr())
    )
  }

  override predicate isSink(DataFlow::Node node) {
    exists(TSSDeleteFunctionCall tsd, Expr e |
      // the only requirement of a sink is that at some point
      // it references the key of a delete call.
      e.getParent*() = tsd.getKey() and
      (e = node.asDefiningArgument() or e = node.asExpr())
    )
  }
}

class TssCreateToFreeDataFlowConfiguration extends DataFlow::Configuration {
  TssCreateToFreeDataFlowConfiguration() { this = "TssCreateToFreeDataFlowConfiguration" }

  override predicate isSource(DataFlow::Node node) {
    exists(TSSCreateFunctionCall tsc, Expr e |
      // the only requirement of the source is that at some point
      // it refers to the key of a create statement
      e.getParent*() = tsc.getKey() and
      (e = node.asDefiningArgument() or e = node.asExpr())
    )
  }

  override predicate isSink(DataFlow::Node node) {
    exists(TSSGetFunctionCall tsg, FreeFunctionCall ffc, Expr e |
      // the only requirement of a sink is that at some point
      // it references the key of a delete call.
      e.getParent*() = tsg.getKey() and
      (e = node.asDefiningArgument() or e = node.asExpr()) and
      ffc.getArgument(0) = tsg
    )
  }
}

from TSSCreateFunctionCall tcc
where
  not isExcluded(tcc, Concurrency4Package::cleanUpThreadSpecificStorageQuery()) and
  if tcc.hasDeallocator()
  then
    // if they specify a deallocator the memory must be freed with a call to
    // tss_delete(key), which implies that there is dataflow from the create call
    // to the delete call
    not exists(TssCreateToTssDeleteDataFlowConfiguration config |
      config.hasFlow(DataFlow::definitionByReferenceNodeFromArgument(tcc.getKey()), _)
      or
      config.hasFlow(DataFlow::exprNode(tcc.getKey()), _)
    )
  else
    // otherwise, they are required to call some kind of free on the result of
    // a key which has dataflow of the form tss_create -> tss_get -> free.
    not exists(TssCreateToFreeDataFlowConfiguration config |
      config.hasFlow(DataFlow::definitionByReferenceNodeFromArgument(tcc.getKey()), _)
      or
      config.hasFlow(DataFlow::exprNode(tcc.getKey()), _)
    )
select tcc

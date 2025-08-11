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
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.ConcurrencyNew
import semmle.code.cpp.dataflow.new.DataFlow

newtype Direction =
  Incoming() or
  Outgoing()

predicate isSource(DataFlow::Node node, Direction d) {
  exists(TSSCreateFunctionCall tsc, Expr e |
    // the only requirement of the source is that at some point
    // it refers to the key of a create statement
    e.getParent*() = tsc.getKey()
  |
    d = Outgoing() and
    e = [node.asExpr(), node.asDefiningArgument()]
    or
    d = Incoming() and
    e = [node.asExpr(), node.asIndirectArgument()]
  )
}

module TssCreateToTssDeleteConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) { isSource(node, Outgoing()) }

  predicate isBarrierIn(DataFlow::Node node) { isSource(node, Incoming()) }

  predicate isSink(DataFlow::Node node) {
    exists(TSSDeleteFunctionCall tsd, Expr e |
      // the only requirement of a sink is that at some point
      // it references the key of a delete call.
      e.getParent*() = tsd.getKey() and
      (e = node.asDefiningArgument() or e = node.asExpr())
    )
  }
}

module TssCreateToTssDeleteFlow = DataFlow::Global<TssCreateToTssDeleteConfig>;

from TSSCreateFunctionCall tcfc
where
  not isExcluded(tcfc, Concurrency4Package::cleanUpThreadSpecificStorageQuery()) and
  // all calls to `tss_create` must be bookended by calls to tss_delete
  // even if a thread is not created.
  not (
    TssCreateToTssDeleteFlow::flow(DataFlow::definitionByReferenceNodeFromArgument(tcfc.getKey()), _)
    or
    TssCreateToTssDeleteFlow::flow(DataFlow::exprNode(tcfc.getKey()), _)
  )
  or
  // if a thread is created, we must check additional items
  exists(C11ThreadCreateCall tcc |
    tcfc.getASuccessor*() = tcc and
    if tcfc.hasDeallocator()
    then
      // if they specify a deallocator, they must wait for this thread to finish, otherwise
      // automatic calls to the deallocator will not work.
      not exists(ThreadWait tw | tcc.getASuccessor*() = tw)
      or
      // freeing memory twice can lead to errors; because of this we report cases
      // where a deallocator is specified but free is called explicitly.
      getAThreadSpecificStorageDeallocationCall(tcc, _)
    else
      // otherwise, we require that the thread that gets called calls a free like
      // function with the argument of a `tss_get` call.
      not getAThreadSpecificStorageDeallocationCall(tcc, _)
  )
select tcfc, "Resources used by thread specific storage may not be cleaned up."

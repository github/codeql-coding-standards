/**
 * @id c/cert/thread-object-storage-durations-not-initialized
 * @name CON34-C: (Audit) Declare objects shared between threads with appropriate storage durations
 * @description Storage durations not correctly initialized can cause unpredictable program
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con34-c
 *       external/cert/audit
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Concurrency
import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.dataflow.DataFlow

from TSSGetFunctionCall tsg, ThreadedFunction tf
where
  not isExcluded(tsg, Concurrency4Package::threadObjectStorageDurationsNotInitializedQuery()) and
  // from within a threaded function there is a call to tsg
  tsg.getEnclosingFunction() = tf and
  // however, there does not exist a proper sequencing.
  not exists(TSSSetFunctionCall tss, DataFlow::Node src |
    // there should be dataflow from somewhere (the same somewhere)
    // into each of the first arguments
    DataFlow::localFlow(src, DataFlow::exprNode(tsg.getArgument(0))) and
    DataFlow::localFlow(src, DataFlow::exprNode(tss.getArgument(0)))
  )
select tsg,
  "Call to a thread specific storage function from within a threaded context on an object that may not be owned by this thread."

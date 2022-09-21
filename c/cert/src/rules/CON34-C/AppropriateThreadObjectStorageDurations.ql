/**
 * @id c/cert/appropriate-thread-object-storage-durations
 * @name CON34-C: Declare objects shared between threads with appropriate storage durations
 * @description Accessing thread-local variables with automatic storage durations can lead to
 *              unpredictable program behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con34-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Concurrency
import semmle.code.cpp.dataflow.TaintTracking


/// anything from tss_get is ok. the tss get must obtain the value from the
//  context that called tss_set NOT in the thread. 
/// anything that was static is ok
/// anything dynamically allocated is ok. 

// THREAD LOCAL IS NOT OK -- EG STACK VARIBLES ARE NEVER OK

// we can make this really simple -- just look for thread create functions
// wherein you pass in a variable created on the stack that is a) not static or
// b) not created via malloc and c) not obtained from tss_get. 
// we should do something more to determine if tss_get is wrongly called from a
// thread context without a matching tss_get as another query. That should be an
// audit. tss get without set. 
// tss_get in the parent thread should maybe be followed by a thread_join
// function 
// 
// 

// IN THE PARENT -- a call to tss_set MUST be followed by a thread_join. 
// Without this, it is possible the context isn't valid anymore.

// It's important to note -- tss_get set DOES NOT require a call to delete 
// to require the wait. It just requires the wait if it is used at all. 

class MallocFunctionCall extends FunctionCall {
  MallocFunctionCall(){
    getTarget().getName() = "malloc"
  }
}

from MallocFunctionCall fc, StackVariable sv, Expr e
where not isExcluded(fc) 
and TaintTracking::localTaint(DataFlow::exprNode(fc), DataFlow::exprNode(e)) 
select fc, e


// from C11ThreadCreateCall tcc, StackVariable sv, Expr arg
// where
//   not isExcluded(tcc, Concurrency4Package::appropriateThreadObjectStorageDurationsQuery()) and
//   tcc.getArgument(2) = arg and 
//   // a stack variable that is given as an argument to a thread
//   TaintTracking::localTaint(DataFlow::exprNode(sv.getAnAccess()), DataFlow::exprNode(arg)) 
//   // that isn't one of the allowed usage patterns
//   TaintTracking::localTaint(DataFlow::exprNode(sv.getAnAccess()), DataFlow::exprNode(arg)) 
// select tcc, "$@ not declared with appropriate storage duration", arg, "Shared object"

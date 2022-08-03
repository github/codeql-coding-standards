/**
 * @id cpp/cert/do-not-allow-a-mutex-to-go-out-of-scope-while-locked
 * @name CON50-CPP: Do not destroy a mutex while it is locked
 * @description Allowing a mutex to go out of scope while it is locked removes protections around
 *              shared resources.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con50-cpp
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Concurrency
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.dataflow.TaintTracking

/*
 * This query finds potential misuse of mutexes passed to threads by considering
 * cases where the underlying mutex is a local variable; such a variable would
 * go out of scope at the end of the calling function and thus would potentially
 * create issues for the thread depending on the mutex. This query is primarily 
 * targeted at C usages since in the case of CPP, many more cases can be covered
 * via tracking of destructors. The main difference is that this query doesn't 
 * expect an explicitly deleted call to be made. 
 *
 * In order to safely destroy a dependent mutex, it is necessary both to not delete 
 * it, but also if deletes do happen, one must wait for a thread to exit prior to 
 * deleting it. We broadly model this by using standard language support for thread
 * synchronization. 
 */
from ThreadDependentMutex dm, LocalVariable lv 
where 
  not isExcluded(dm.asExpr(), ConcurrencyPackage::doNotDestroyAMutexWhileItIsLockedQuery()) and
  not isExcluded(lv, ConcurrencyPackage::doNotDestroyAMutexWhileItIsLockedQuery()) and
  not lv.isStatic() and 
  TaintTracking::localTaint(dm.getAUsage(), DataFlow::exprNode(lv.getAnAssignedValue())) 
  // ensure that each dependent thread is followed by some sort of joining
  // behavior. 
  and exists(DataFlow::Node n | n = dm.getADependentThreadCreationExpr()  | forall(ThreadWait tw |
    not (tw = n.asExpr().getASuccessor*())
  ))

  select dm, "Mutex used by thread potentially destroyed while in use."

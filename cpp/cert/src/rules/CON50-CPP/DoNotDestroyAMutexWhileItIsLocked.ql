/**
 * @id cpp/cert/do-not-destroy-a-mutex-while-it-is-locked
 * @name CON50-CPP: Do not destroy a mutex while it is locked
 * @description Calling delete on a locked mutex removes protections around shared resources.
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
 * cases where the underlying mutex may be deleted explicitly. The scope of this
 * query is that it considers this behavior locally within the procedure. We do
 * this by looking for cases where the mutex is the target of a delete within
 * the same procedure following the creation of the thread.
 *
 * It is of course possible to safely use such a pattern. A safe usage of this
 * pattern one would perform some sort of waiting or looping or control after
 * passing such a mutex in. For this reason we perform a broad analysis that
 * looks for waiting-like behavior following the call to `std::thread`. Since
 * there are a wide variety of correct behaviors that may be called we take the
 * very broad view that calling the `join` method subsequent to creating the
 * thread is enough to classify as "correct behavior."
 */

from MutexDependentThreadConstructor cc, DeleteExpr deleteExpr, VariableAccess va
where
  not isExcluded(cc, ConcurrencyPackage::doNotDestroyAMutexWhileItIsLockedQuery()) and
  deleteExpr = cc.getASuccessor*() and
  DataFlow::localFlow(DataFlow::exprNode(va), DataFlow::exprNode(cc.dependentMutex())) and
  deleteExpr.getExpr() = va.getTarget().getAnAccess() and
  // exempt cases where some "waiting like" behavior is detected
  not exists(ThreadWait tw |
    TaintTracking::localTaint(DataFlow::exprNode(cc), DataFlow::exprNode(tw.getQualifier()))
  )
select cc, "Mutex used by thread potentially deleted while in use."

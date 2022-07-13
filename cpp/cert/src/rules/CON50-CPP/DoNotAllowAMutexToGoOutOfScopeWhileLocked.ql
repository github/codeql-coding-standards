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
 * cases where the underlying mutex is a stack variable; such a variable would
 * go out of scope at the end of the calling function and thus would potentially
 * create issues for the thread depending on the mutex.
 *
 * It is of course possible to safely use such a pattern. A safe usage of this
 * pattern one would perform some sort of waiting or looping or control after
 * passing such a mutex in. For this reason we perform a broad analysis that
 * looks for waiting-like behavior following the call to `std::thread`. Since
 * there are a wide variety of correct behaviors that may be called we take the
 * very broad view that calling the `join` method subsequent to creating the
 * thread is enough to classify as "correct behavior."
 */

from MutexDependentThreadConstructor cc, StackVariable sv
where
  not isExcluded(cc, ConcurrencyPackage::doNotAllowAMutexToGoOutOfScopeWhileLockedQuery()) and
  not isExcluded(sv, ConcurrencyPackage::doNotAllowAMutexToGoOutOfScopeWhileLockedQuery()) and
  // find cases where stack local variable has flowed into a thread mutex argument
  DataFlow::localFlow(DataFlow::exprNode(sv.getAnAccess()), DataFlow::exprNode(cc.dependentMutex())) and
  // exempt cases where some "waiting like" behavior is detected
  not exists(ThreadWait tw |
    TaintTracking::localTaint(DataFlow::exprNode(cc), DataFlow::exprNode(tw.getQualifier()))
  )
select cc, "Mutex used by thread potentially destroyed while in use."

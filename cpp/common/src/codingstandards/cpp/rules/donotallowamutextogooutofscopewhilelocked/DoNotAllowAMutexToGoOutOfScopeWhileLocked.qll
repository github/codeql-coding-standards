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

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Concurrency
import semmle.code.cpp.dataflow.TaintTracking

abstract class DoNotAllowAMutexToGoOutOfScopeWhileLockedSharedQuery extends Query { }

Query getQuery() { result instanceof DoNotAllowAMutexToGoOutOfScopeWhileLockedSharedQuery }

query predicate problems(ThreadDependentMutex dm, string message) {
  not isExcluded(dm.asExpr(), getQuery()) and
  exists(LocalVariable lv |
    not isExcluded(lv, getQuery()) and
    not lv.isStatic() and
    TaintTracking::localTaint(dm.getAUsage(), DataFlow::exprNode(lv.getAnAssignedValue())) and
    // ensure that each dependent thread is followed by some sort of joining
    // behavior.
    exists(DataFlow::Node n | n = dm.getADependentThreadCreationExpr() |
      forall(ThreadWait tw | not tw = n.asExpr().getASuccessor*())
    ) and
    message = "Mutex used by thread potentially destroyed while in use."
  )
}

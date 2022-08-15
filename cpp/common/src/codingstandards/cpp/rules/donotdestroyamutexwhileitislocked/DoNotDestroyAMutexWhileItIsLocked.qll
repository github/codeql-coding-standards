/*
 * This query finds potential misuse of mutexes passed to threads by considering
 * cases where the underlying mutex may be destroyed. The scope of this query is
 * that it performs this analysis both locally within the function but can also
 * look through to the called thread to identify mutexes it may not own.
 * query is that it considers this behavior locally within the procedure.
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

abstract class DoNotDestroyAMutexWhileItIsLockedSharedQuery extends Query { }

Query getQuery() { result instanceof DoNotDestroyAMutexWhileItIsLockedSharedQuery }

query predicate problems(
  ThreadDependentMutex dm, string message, MutexDestroyer md, string mdMessage
) {
  not isExcluded(dm.asExpr(), getQuery()) and
  not isExcluded(md, getQuery()) and
  // find all instances where a usage of a dependent mutex flows into a
  // expression that will destroy it.
  TaintTracking::localTaint(dm.getAUsage(), DataFlow::exprNode(md.getMutexExpr())) and
  (
    // firstly, we assume it is never safe to destroy a global mutex, but it is
    // difficult to make assumptions about the intended control flow. Note that
    // this means the point at where the mutex is defined -- not where the variable
    // that contains it is scoped -- a `ThreadDependentMutex` is bound to the
    // function that creates an initialized mutex. For example, in `C`
    // `mtx_init` is called to initialize the mutex and in C++, the constructor
    // of std::mutex is called.
    not exists(dm.asExpr().getEnclosingFunction())
    or
    // secondly, we assume it is never safe to destroy a mutex created by
    // another function scope -- which includes trying to destroy a mutex that
    // was passed into a function.
    not md.getMutexExpr().getEnclosingFunction() = dm.asExpr().getEnclosingFunction()
    or
    // this leaves only destructions of mutexes locally near the thread that may
    // consume them. We allow this only if there has been some effort to
    // synchronize the threads prior to destroying the mutex.
    not exists(ThreadWait tw | tw = md.getAPredecessor*())
  ) and
  message = "Mutex used by thread potentially $@ while in use." and
  mdMessage = "destroyed"
}

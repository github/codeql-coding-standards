/**
 * Provides a library which includes a `problems` predicate for locks that do not
 * lock in a predefined order.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Concurrency
import semmle.code.cpp.controlflow.Dominance

abstract class PreventDeadlockByLockingInPredefinedOrderSharedQuery extends Query { }

Query getQuery() { result instanceof PreventDeadlockByLockingInPredefinedOrderSharedQuery }

/**
 * Gets a pair of locks guarding a `LockProtectedControlFlowNode` in an order
 * specified by the locking function's call site.
 */
pragma[inline]
predicate getAnOrderedLockPair(
  FunctionCall lock1, FunctionCall lock2, LockProtectedControlFlowNode node
) {
  lock1 = node.coveredByLock() and
  lock2 = node.coveredByLock() and
  not lock1 = lock2 and
  exists(Function f |
    lock1.getEnclosingFunction() = f and
    lock2.getEnclosingFunction() = f and
    node.getBasicBlock().getEnclosingFunction() = f
  ) and
  exists(Location l1Loc, Location l2Loc |
    l1Loc = lock1.getLocation() and
    l2Loc = lock2.getLocation()
  |
    l1Loc.getEndLine() < l2Loc.getStartLine()
    or
    l1Loc.getStartLine() = l2Loc.getEndLine() and
    l1Loc.getEndColumn() < l2Loc.getStartColumn()
  )
}

/*
 * There are two ways to safely avoid deadlock. One involves doing the locking
 * in a specific order that is guaranteed to be the same across all thread
 * invocations. This is especially hard to check and thus we adopt an
 * alternative viewpoint wherein we view a "safe" usage of multiple locks to be
 * one that uses the built in `std::lock` functionality which avoids this
 * problem.
 *
 * To properly deadlock, a thread must have at least two different locks (i.e.,
 * mutual exclusion) which are used in an order that causes a problem.  Thus we
 * look for functions with CFNs wherein there may be two locks active at the
 * same time that are invoked from a thread.
 */

predicate isUnSerializedLock(LockingOperation lock) {
  exists(VariableAccess va |
    va = lock.getArgument(0).getAChild().(VariableAccess) and
    not exists(Assignment assn |
      assn = va.getTarget().getAnAssignment() and
      not bbDominates(assn.getBasicBlock(), lock.getBasicBlock())
    )
  )
}

predicate isSerializedLock(LockingOperation lock) { not isUnSerializedLock(lock) }

query predicate problems(
  Function f, string message, FunctionCall lock1, string lock1String, FunctionCall lock2,
  string lock2String
) {
  exists(LockProtectedControlFlowNode node |
    not isExcluded(node, getQuery()) and
    // we can get into trouble when we get into a situation where there may be two
    // locks in the same threaded function active at the same time.
    // simple ordering is applied here for presentation purposes.
    getAnOrderedLockPair(lock1, lock2, node) and
    // it is difficult to determine if the ordering applied to the locks is "safe"
    // so here we simply look to see that there exists at least one other program
    // path that would yield different argument values to the lock functions
    // perhaps arising from some logic that applies an ordering to the locking.
    not (isSerializedLock(lock1) and isSerializedLock(lock2)) and
    // To reduce the noise (and increase usefulness) we alert the user at the
    // level of the function, which is the unit the synchronization should be
    // performed.
    f = node.getEnclosingStmt().getEnclosingFunction() and
    // Because `std::lock` isn't included in our definition of a 'lock'
    // it is not necessary to check to see if it is in fact what is protecting
    // these CNFs.
    // However, to reduce noise, we shall require that the function we are
    // reporting makes some sort of locking call since this is likely where the
    // user intends to perform the locking operations. Our implementation will
    // currently look into all of these nodes which is less helpful for the user
    // but useful for our analysis.
    any(LockingOperation l).getEnclosingFunction() = f and
    lock1String = "lock 1" and
    lock2String = "lock 2"
  ) and
  message =
    "Threaded function may be called from a context that uses $@ and $@ which may lead to deadlocks."
}

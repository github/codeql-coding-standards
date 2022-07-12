/**
 * @id cpp/cert/deadlock-by-locking-in-predefined-order
 * @name CON53-CPP: Avoid deadlock by locking in a predefined order
 * @description Circular waits leading to thread deadlocks may be avoided by locking in a predefined
 *              order.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/con53-cpp
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Concurrency

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
  lock1.getFile() = lock2.getFile() and
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

from LockProtectedControlFlowNode node, Function f, FunctionCall lock1, FunctionCall lock2
where
  not isExcluded(node, ConcurrencyPackage::deadlockByLockingInPredefinedOrderQuery()) and
  // we can get into trouble when we get into a situation where there may be two
  // locks in the same threaded function active at the same time.
  // simple ordering
  // lock1 = node.coveredByLock() and
  // lock2 = node.coveredByLock() and
  getAnOrderedLockPair(lock1, lock2, node) and
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
  any(LockingOperation l).getEnclosingFunction() = f
select f,
  "Threaded function may be called from a context that uses $@ and $@ which may lead to deadlocks.",
  lock1, "lock 1", lock2, "lock 2"

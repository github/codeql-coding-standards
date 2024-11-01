/**
 * @id c/misra/not-no-deadlocks-between-threads
 * @name DIR-5-2: There shall be no deadlocks between threads
 * @description Circular waits leading to thread deadlocks may be avoided by locking in a predefined
 *              order.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/dir-5-2
 *       external/misra/c/2012/amendment4
 *       correctness
 *       concurrency
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.preventdeadlockbylockinginpredefinedorder.PreventDeadlockByLockingInPredefinedOrder

class NotNoDeadlocksBetweenThreadsQuery extends PreventDeadlockByLockingInPredefinedOrderSharedQuery
{
  NotNoDeadlocksBetweenThreadsQuery() {
    this = Concurrency6Package::notNoDeadlocksBetweenThreadsQuery()
  }
}

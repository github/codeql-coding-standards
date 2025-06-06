/**
 * @id c/cert/deadlock-by-locking-in-predefined-order
 * @name CON35-C: Avoid deadlock by locking in a predefined order
 * @description Circular waits leading to thread deadlocks may be avoided by locking in a predefined
 *              order.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con35-c
 *       correctness
 *       concurrency
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.preventdeadlockbylockinginpredefinedorder.PreventDeadlockByLockingInPredefinedOrder

class DeadlockByLockingInPredefinedOrderQuery extends PreventDeadlockByLockingInPredefinedOrderSharedQuery
{
  DeadlockByLockingInPredefinedOrderQuery() {
    this = Concurrency2Package::deadlockByLockingInPredefinedOrderQuery()
  }
}

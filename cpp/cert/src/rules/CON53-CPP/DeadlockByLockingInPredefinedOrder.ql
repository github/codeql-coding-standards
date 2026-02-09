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
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.preventdeadlockbylockinginpredefinedorder.PreventDeadlockByLockingInPredefinedOrder

class DeadlockByLockingInPredefinedOrderQuery extends PreventDeadlockByLockingInPredefinedOrderSharedQuery
{
  DeadlockByLockingInPredefinedOrderQuery() {
    this = ConcurrencyPackage::deadlockByLockingInPredefinedOrderQuery()
  }
}

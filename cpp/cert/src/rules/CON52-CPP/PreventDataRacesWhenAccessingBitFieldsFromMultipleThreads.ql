/**
 * @id cpp/cert/prevent-data-races-when-accessing-bit-fields-from-multiple-threads
 * @name CON52-CPP: Prevent data races when accessing bit-fields from multiple threads
 * @description Accesses to bit fields without proper concurrency protection can result in data
 *              races.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con52-cpp
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Concurrency

class BitFieldAccess extends VariableAccess {
  BitFieldAccess() { this.getTarget() instanceof BitField }
}

/**
 * Returns a `ControlFlowNode` reachable from this locked `MutexFunctionCall`.
 */
ControlFlowNode getAReachableLockCFN(MutexFunctionCall mfc) {
  mfc.isLock() and
  (
    mfc = result //base
    or
    exists(ControlFlowNode mid |
      mid = getAReachableLockCFN(mfc) and
      result = mid.getASuccessor() and
      not result.(MutexFunctionCall).unlocks(mfc)
    )
  )
}

// This query checks to see that accesses to a bit field are protected by a
// mutex of some sort. There are two main types, the manual ones managed with
// lock/unlock and the RAII-style ones such as std::lock_guard,
// std::scoped_lock. This query essentially checks to see that at the program
// point where the bit field access happens that either a) a RAII-style lock is
// in scope or b) a lock is held manually. One issue with this query is that it
// has no way of determining that code is indeed multi-threaded.
from BitFieldAccess ba
where
  not isExcluded(ba,
    ConcurrencyPackage::preventDataRacesWhenAccessingBitFieldsFromMultipleThreadsQuery()) and
  ba instanceof ThreadedCFN and
  not ba instanceof LockProtectedControlFlowNode
select ba, "Access to a bit-field without a concurrency guard."

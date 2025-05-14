/**
 * @id cpp/cert/ensure-actively-held-locks-are-released-on-exceptional-conditions
 * @name CON51-CPP: Ensure actively held locks are released on exceptional conditions
 * @description A program that fails to release a lock on exceptional conditions will leave a lock
 *              in the locked state which will block other critical sections from executing
 *              properly.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con51-cpp
 *       correctness
 *       concurrency
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.Concurrency

from LockProtectedControlFlowNode lpn
where
  not isExcluded(lpn,
    ConcurrencyPackage::ensureActivelyHeldLocksAreReleasedOnExceptionalConditionsQuery()) and
  // analyze every node that is protected by a lock which is not
  // the lock itself
  not lpn.coveredByLock() = lpn and
  // if it is a an expression that can throw
  lpn instanceof ThrowingExpr and
  // The graph of `LockProtectedNode` looks thru procedures which can be noisy.
  // To reduce the number of results we require that this is a direct child
  // of the lock within the same function
  lpn.coveredByLock().getASuccessor*() = lpn and
  // report those expressions for which there doesn't exist a catch block
  not exists(CatchBlock cb |
    catches(cb, lpn, _) and
    // however, only permit catch blocks which also perform an unlock
    exists(MutexFunctionCall unlock |
      unlock.getAPredecessor*() = cb and unlock.unlocks(lpn.coveredByLock())
    )
  )
select lpn,
  "Expression that may throw an exception is not surrounded by a try/catch that ensures the $@ is properly released.",
  lpn.coveredByLock(), "locked mutex"

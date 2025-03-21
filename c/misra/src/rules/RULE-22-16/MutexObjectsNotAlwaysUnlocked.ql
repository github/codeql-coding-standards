/**
 * @id c/misra/mutex-objects-not-always-unlocked
 * @name RULE-22-16: All mutex objects locked by a thread shall be explicitly unlocked by the same thread
 * @description Mutex not unlocked by thread on all execution paths in current thread after being
 *              locked.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-22-16
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Concurrency
import codingstandards.cpp.resources.ResourceLeakAnalysis

module MutexLeakConfig implements ResourceLeakConfigSig {
  predicate isAllocate(ControlFlowNode allocPoint, DataFlow::Node node) {
    exists(MutexFunctionCall lock |
      allocPoint = lock and
      lock.isLock() and
      node.asDefiningArgument() = lock.getLockExpr()
    )
  }

  predicate isFree(ControlFlowNode node, DataFlow::Node resource) {
    exists(MutexFunctionCall mfc |
      node = mfc and
      mfc.isUnlock() and
      mfc.getLockExpr() = resource.asExpr()
    )
  }
}

string describeMutex(Expr mutexExpr) {
  if mutexExpr instanceof AddressOfExpr
  then result = mutexExpr.(AddressOfExpr).getOperand().toString()
  else result = mutexExpr.toString()
}

from MutexFunctionCall lockCall, string mutexDescription
where
  not isExcluded(lockCall, Concurrency8Package::mutexObjectsNotAlwaysUnlockedQuery()) and
  //lockCall.getLockExpr() = mutexNode.asDefiningArgument() and
  exists(ResourceLeak<MutexLeakConfig>::getALeak(lockCall)) and
  mutexDescription = describeMutex(lockCall.getLockExpr())
select lockCall,
  "Mutex '" + mutexDescription + "' is locked here and may not always be subsequently unlocked."

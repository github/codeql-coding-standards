/**
 * @id c/misra/thread-resource-disposed-before-threads-joined
 * @name RULE-22-15: Thread synchronization objects and thread-specific storage pointers shall not be disposed unsafely
 * @description Thread synchronization objects and thread-specific storage pointers shall not be
 *              destroyed until after all threads accessing them have terminated.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-22-15
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.SubObjects
import codingstandards.cpp.Concurrency

newtype TThreadKind =
  TSpawned(C11ThreadCreateCall tcc) or
  TMainThread()

TThreadKind getThreadKind(FunctionCall operation) {
  if
    not exists(C11ThreadCreateCall tcc |
      getAThreadContextAwareSuccessor(tcc.getFunction().getEntryPoint()) = operation
    )
  then result = TMainThread()
  else
    exists(C11ThreadCreateCall tcc |
      getAThreadContextAwareSuccessor(tcc.getFunction().getEntryPoint()) = operation and
      result = TSpawned(tcc)
    )
}

bindingset[tcc, thread]
predicate followsMainThreadTcc(C11ThreadCreateCall tcc, TThreadKind thread) {
  thread = TMainThread()
  or
  exists(C11ThreadCreateCall tcc2 |
    getAThreadContextAwareSuccessor(tcc) = tcc2 and
    thread = TSpawned(tcc2)
  )
}

string describeThread(TThreadKind thread) {
  thread = TMainThread() and
  result = "main thread"
  or
  exists(C11ThreadCreateCall tcc2 |
    thread = TSpawned(tcc2) and
    result = tcc2.getFunction().getName()
  )
}

bindingset[alternative]
Element elementOr(TThreadKind thread, Element alternative) {
  thread = TMainThread() and
  result = alternative
  or
  exists(C11ThreadCreateCall tcc2 |
    thread = TSpawned(tcc2) and
    result = tcc2
  )
}

from
  FunctionCall dispose, FunctionCall use, C11ThreadCreateCall tcc, TThreadKind disposeThread,
  TThreadKind useThread, SubObject usedAndDestroyed
where
  not isExcluded(dispose, Concurrency9Package::threadResourceDisposedBeforeThreadsJoinedQuery()) and
  // `tcc` may be the thread that uses the resource, or the thread that disposes it. What matters
  // for the query is that `tcc` is before the use and the dispose.
  dispose = getAThreadContextAwareSuccessor(tcc) and
  (
    // Lock and dispose of mtx_t:
    exists(CMutexFunctionCall mfc, C11MutexDestroyer md | dispose = md and use = mfc |
      mfc = getAThreadContextAwareSuccessor(tcc) and
      mfc.getLockExpr() = usedAndDestroyed.getAnAddressOfExpr() and
      md.getMutexExpr() = usedAndDestroyed.getAnAddressOfExpr()
    )
    or
    // Read/store and dispose of tss_t:
    exists(ThreadSpecificStorageFunctionCall tssfc, TSSDeleteFunctionCall td |
      dispose = td and use = tssfc
    |
      tssfc = getAThreadContextAwareSuccessor(tcc) and
      tssfc.getKey() = usedAndDestroyed.getAnAddressOfExpr() and
      td.getKey() = usedAndDestroyed.getAnAddressOfExpr()
    )
    or
    // Wait and dispose of cnd_t:
    exists(CConditionOperation cndop, C11ConditionDestroyer cd | dispose = cd and use = cndop |
      cndop = getAThreadContextAwareSuccessor(tcc) and
      cndop.getConditionExpr() = usedAndDestroyed.getAnAddressOfExpr() and
      cd.getConditionExpr() = usedAndDestroyed.getAnAddressOfExpr()
    )
  ) and
  // Dispose could be in the main thread or in a spawned thread.
  disposeThread = getThreadKind(dispose) and
  // Dispose could be in the main thread or in a spawned thread.
  useThread = getThreadKind(use) and
  // Exclude a thread that does not concurrently share the resource it disposed (unlikely).
  not useThread = disposeThread and
  followsMainThreadTcc(tcc, useThread) and
  followsMainThreadTcc(tcc, disposeThread) and
  // If there is a join between the use and the dispose, the code is compliant.
  not getAThreadContextAwarePredecessor(elementOr(useThread, use), dispose) instanceof C11ThreadWait
select dispose, "Thread resource $@ disposed before joining thread $@ which uses it.",
  usedAndDestroyed.getRootIdentity(), usedAndDestroyed.toString(), elementOr(useThread, use),
  describeThread(useThread)

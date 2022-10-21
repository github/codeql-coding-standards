/**
 * @id c/cert/thread-was-previously-joined-or-detached
 * @name CON39-C: Do not join or detach a thread that was previously joined or detached
 * @description Joining or detaching a previously joined or detached thread can lead to undefined
 *              program behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con39-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Concurrency

// OK
// 1) Thread calls detach parent DOES NOT call join
// 2) Parent calls join, thread does NOT call detach()
// NOT OK
// 1) Thread calls detach, parent calls join
// 2) Thread calls detach twice, parent does not call join
// 3) Parent calls join twice, thread does not call detach
from C11ThreadCreateCall tcc
where
  not isExcluded(tcc, Concurrency5Package::threadWasPreviouslyJoinedOrDetachedQuery()) and
  // Note: These cases can be simplified but they are presented like this for clarity
  // case 1 - calls to `thrd_join` and `thrd_detach` within the parent or
  // within the parent / child CFG.
  exists(C11ThreadWait tw, C11ThreadDetach dt |
    tw = getAThreadContextAwareSuccessor(tcc) and
    dt = getAThreadContextAwareSuccessor(tcc)
  )
  or
  // case 2 - multiple calls to `thrd_detach` within the threaded CFG.
  exists(C11ThreadDetach dt1, C11ThreadDetach dt2 |
    dt1 = getAThreadContextAwareSuccessor(tcc) and
    dt2 = getAThreadContextAwareSuccessor(tcc) and
    not dt1 = dt2
  )
  or
  // case 3 - multiple calls to `thrd_join` within the threaded CFG.
  exists(C11ThreadWait tw1, C11ThreadWait tw2 |
    tw1 = getAThreadContextAwareSuccessor(tcc) and
    tw2 = getAThreadContextAwareSuccessor(tcc) and
    not tw1 = tw2
  )
select tcc, "Thread may call join or detach after the thread is joined or detached."

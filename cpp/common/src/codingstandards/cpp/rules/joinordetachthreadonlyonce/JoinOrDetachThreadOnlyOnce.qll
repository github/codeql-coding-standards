/**
 * Provides a library with a `problems` predicate for the following issue:
 * Joining or detaching a previously joined or detached thread can lead to undefined
 * program behavior.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Concurrency

abstract class JoinOrDetachThreadOnlyOnceSharedQuery extends Query { }

Query getQuery() { result instanceof JoinOrDetachThreadOnlyOnceSharedQuery }

// OK
// 1) Thread calls detach parent DOES NOT call join
// 2) Parent calls join, thread does NOT call detach()
// NOT OK
// 1) Thread calls detach, parent calls join
// 2) Thread calls detach twice, parent does not call join
// 3) Parent calls join twice, thread does not call detach
query predicate problems(C11ThreadCreateCall tcc, string message) {
  not isExcluded(tcc, getQuery()) and
  message = "Thread may call join or detach after the thread is joined or detached." and
  (
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
  )
}

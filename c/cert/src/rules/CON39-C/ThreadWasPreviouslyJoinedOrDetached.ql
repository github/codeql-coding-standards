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
 *       external/cert/severity/low
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.joinordetachthreadonlyonce.JoinOrDetachThreadOnlyOnce

class ThreadWasPreviouslyJoinedOrDetachedQuery extends JoinOrDetachThreadOnlyOnceSharedQuery {
  ThreadWasPreviouslyJoinedOrDetachedQuery() {
    this = Concurrency5Package::threadWasPreviouslyJoinedOrDetachedQuery()
  }
}

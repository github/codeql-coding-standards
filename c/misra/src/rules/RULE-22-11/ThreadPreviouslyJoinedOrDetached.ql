/**
 * @id c/misra/thread-previously-joined-or-detached
 * @name RULE-22-11: A thread that was previously either joined or detached shall not be subsequently joined nor detached
 * @description Joining or detaching a previously joined or detached thread can lead to undefined
 *              program behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-22-11
 *       external/misra/c/2012/amendment4
 *       correctness
 *       concurrency
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.joinordetachthreadonlyonce.JoinOrDetachThreadOnlyOnce

class ThreadPreviouslyJoinedOrDetachedQuery extends JoinOrDetachThreadOnlyOnceSharedQuery {
  ThreadPreviouslyJoinedOrDetachedQuery() {
    this = Concurrency6Package::threadPreviouslyJoinedOrDetachedQuery()
  }
}

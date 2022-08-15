/**
 * @id c/cert/do-not-allow-a-mutex-to-go-out-of-scope-while-locked
 * @name CON31-C: Do not destroy a mutex while it is locked
 * @description Allowing a mutex to go out of scope while it is locked removes protections around
 *              shared resources.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con31-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.donotallowamutextogooutofscopewhilelocked.DoNotAllowAMutexToGoOutOfScopeWhileLocked

class DoNotAllowAMutexToGoOutOfScopeWhileLockedQuery extends DoNotAllowAMutexToGoOutOfScopeWhileLockedSharedQuery {
  DoNotAllowAMutexToGoOutOfScopeWhileLockedQuery() {
    this = Concurrency3Package::doNotAllowAMutexToGoOutOfScopeWhileLockedQuery()
  }
}

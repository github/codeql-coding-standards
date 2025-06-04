/**
 * @id cpp/cert/do-not-allow-a-mutex-to-go-out-of-scope-while-locked
 * @name CON50-CPP: Do not destroy a mutex while it is locked
 * @description Allowing a mutex to go out of scope while it is locked removes protections around
 *              shared resources.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con50-cpp
 *       correctness
 *       concurrency
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.donotallowamutextogooutofscopewhilelocked.DoNotAllowAMutexToGoOutOfScopeWhileLocked

class DoNotAllowAMutexToGoOutOfScopeWhileLockedQuery extends DoNotAllowAMutexToGoOutOfScopeWhileLockedSharedQuery
{
  DoNotAllowAMutexToGoOutOfScopeWhileLockedQuery() {
    this = ConcurrencyPackage::doNotAllowAMutexToGoOutOfScopeWhileLockedQuery()
  }
}

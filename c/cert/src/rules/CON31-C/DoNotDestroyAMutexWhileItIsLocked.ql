/**
 * @id c/cert/do-not-destroy-a-mutex-while-it-is-locked
 * @name CON31-C: Do not destroy a mutex while it is locked
 * @description Calling delete on a locked mutex removes protections around shared resources.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con31-c
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
import codingstandards.c.cert
import codingstandards.cpp.rules.donotdestroyamutexwhileitislocked.DoNotDestroyAMutexWhileItIsLocked

class DoNotDestroyAMutexWhileItIsLockedQuery extends DoNotDestroyAMutexWhileItIsLockedSharedQuery {
  DoNotDestroyAMutexWhileItIsLockedQuery() {
    this = Concurrency3Package::doNotDestroyAMutexWhileItIsLockedQuery()
  }
}

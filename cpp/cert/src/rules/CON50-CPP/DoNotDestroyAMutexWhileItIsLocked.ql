/**
 * @id cpp/cert/do-not-destroy-a-mutex-while-it-is-locked
 * @name CON50-CPP: Do not destroy a mutex while it is locked
 * @description Calling delete on a locked mutex removes protections around shared resources.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con50-cpp
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.donotdestroyamutexwhileitislocked.DoNotDestroyAMutexWhileItIsLocked

class DoNotDestroyAMutexWhileItIsLockedQuery extends DoNotDestroyAMutexWhileItIsLockedSharedQuery {
  DoNotDestroyAMutexWhileItIsLockedQuery() {
    this = ConcurrencyPackage::doNotDestroyAMutexWhileItIsLockedQuery()
  }
}

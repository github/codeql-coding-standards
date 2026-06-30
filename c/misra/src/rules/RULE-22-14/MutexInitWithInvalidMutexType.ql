/**
 * @id c/misra/mutex-init-with-invalid-mutex-type
 * @name RULE-22-14: Mutexes shall be initialized with a valid mutex type
 * @description Mutexes shall be initialized with a valid mutex type.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-22-14
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Concurrency

predicate isBaseMutexType(EnumConstantAccess access) {
  access.getTarget().hasName(["mtx_plain", "mtx_timed"])
}

predicate isValidMutexType(Expr expr) {
  isBaseMutexType(expr)
  or
  exists(BinaryBitwiseOperation binOr | binOr = expr |
    isBaseMutexType(binOr.getLeftOperand()) and
    binOr.getRightOperand().(EnumConstantAccess).getTarget().hasName("mtx_recursive")
  )
}

from C11MutexSource init
where
  not isExcluded(init, Concurrency8Package::mutexInitWithInvalidMutexTypeQuery()) and
  not isValidMutexType(init.getMutexTypeExpr())
select init, "Mutex initialized with incorrect type expression."

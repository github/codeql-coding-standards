/**
 * @id c/misra/mutex-not-initialized-before-use
 * @name RULE-22-14: Thread synchronization objects shall be initialized before being accessed
 * @description Mutex and condition objects shall be initialized with the standard library functions
 *              before using them.
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
import codingstandards.c.Objects
import codingstandards.cpp.Concurrency
import codingstandards.cpp.Type
import codingstandards.c.initialization.GlobalInitializationAnalysis

module MutexInitializationConfig implements GlobalInitializationAnalysisConfigSig {
  ObjectIdentity getAnInitializedObject(Expr e) {
    e.(C11MutexSource).getMutexExpr() = result.getASubobjectAddressExpr()
  }

  ObjectIdentity getAUsedObject(Expr e) {
    result.getASubobjectAddressExpr() = e and
    (
      exists(CMutexFunctionCall mutexUse | e = mutexUse.getLockExpr())
      or
      exists(CConditionOperation condOp | e = condOp.getMutexExpr())
    )
  }
}

module ConditionInitializationConfig implements GlobalInitializationAnalysisConfigSig {
  ObjectIdentity getAnInitializedObject(Expr e) {
    exists(CConditionOperation condOp |
      e = condOp and
      condOp.isInit() and
      condOp.getConditionExpr() = result.getASubobjectAddressExpr()
    )
  }

  ObjectIdentity getAUsedObject(Expr e) {
    result.getASubobjectAddressExpr() = e and
    exists(CConditionOperation condOp |
      condOp.isUse() and
      e = condOp.getConditionExpr()
    )
  }
}

import GlobalInitalizationAnalysis<MutexInitializationConfig> as MutexInitAnalysis
import GlobalInitalizationAnalysis<ConditionInitializationConfig> as CondInitAnalysis

from Expr objUse, ObjectIdentity obj, Function callRoot, string typeString, string description
where
  not isExcluded(objUse, Concurrency8Package::mutexNotInitializedBeforeUseQuery()) and
  (
    MutexInitAnalysis::uninitializedFrom(objUse, obj, callRoot) and
    typeString = "Mutex"
    or
    CondInitAnalysis::uninitializedFrom(objUse, obj, callRoot) and
    typeString = "Condition"
  ) and
  (
    if
      obj.getType() instanceof PossiblySpecified<C11MutexType>::Type or
      obj.getType() instanceof PossiblySpecified<C11ConditionType>::Type
    then description = typeString
    else description = typeString + " in object"
  )
select objUse,
  description + " '$@' possibly used before initialization, from entry point function '$@'.", obj,
  obj.toString(), callRoot, callRoot.getName()

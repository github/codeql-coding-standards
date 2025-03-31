/**
 * @id c/misra/thread-storage-not-initialized-before-use
 * @name RULE-22-20: Thread-specific storage pointers shall be created before being accessed
 * @description Thread specific storage pointers shall be initialized with the standard library
 *              functions before using them.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-22-20
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

module ThreadStoreInitializationConfig implements GlobalInitializationAnalysisConfigSig {
  ObjectIdentity getAnInitializedObject(Expr e) {
    e.(TSSCreateFunctionCall).getKey() = result.getASubobjectAddressExpr()
  }

  ObjectIdentity getAUsedObject(Expr e) {
    result.getASubobjectAddressExpr() = e and
    exists(ThreadSpecificStorageFunctionCall use |
      not use instanceof TSSCreateFunctionCall and e = use.getKey()
    )
  }
}

import GlobalInitalizationAnalysis<ThreadStoreInitializationConfig> as InitAnalysis

from Expr objUse, ObjectIdentity obj, Function callRoot
where
  not isExcluded(objUse, Concurrency9Package::threadStorageNotInitializedBeforeUseQuery()) and
  InitAnalysis::uninitializedFrom(objUse, obj, callRoot)
select objUse,
  "Thread specific storage pointer '$@' used before initialization from entry point function '$@'.",
  obj, obj.toString(), callRoot, callRoot.getName()

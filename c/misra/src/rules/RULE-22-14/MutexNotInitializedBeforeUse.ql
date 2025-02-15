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

/** A function which is not called or started as a thread */
class RootFunction extends Function {
  RootFunction() {
    not exists(Function f | f.calls(this)) and
    not this instanceof ThreadedFunction
  }
}

/** A function call which initializes a mutex or a condition */
class ThreadObjectInitialization extends FunctionCall {
  ObjectIdentity owningObject;

  ThreadObjectInitialization() {
    this.(C11MutexSource).getMutexExpr() = owningObject.getASubobjectAddressExpr()
    or
    exists(CConditionOperation condOp |
      this = condOp and
      condOp.isInit() and
      condOp.getConditionExpr() = owningObject.getASubobjectAddressExpr()
    )
  }

  ObjectIdentity getOwningObject() { result = owningObject }
}

/**
 * A function argument where that argument is used as a mutex or condition object.
 */
class ThreadObjectUse extends Expr {
  ObjectIdentity owningObject;
  string typeString;

  ThreadObjectUse() {
    owningObject.getASubobjectAddressExpr() = this and
    (
      exists(CMutexFunctionCall mutexUse | this = mutexUse.getLockExpr()) and
      typeString = "Mutex"
      or
      exists(CConditionOperation condOp | this = condOp.getMutexExpr()) and
      typeString = "Mutex"
      or
      exists(CConditionOperation condOp |
        condOp.isUse() and
        this = condOp.getConditionExpr() and
        typeString = "Condition"
      )
    )
  }

  ObjectIdentity getOwningObject() { result = owningObject }

  string getDescription() {
    if
      getOwningObject().getType() instanceof PossiblySpecified<C11MutexType>::Type or
      getOwningObject().getType() instanceof PossiblySpecified<C11ConditionType>::Type
    then result = typeString
    else result = typeString + " in object"
  }
}

predicate requiresInitializedMutexObject(
  Function func, ThreadObjectUse mutexUse, ObjectIdentity owningObject
) {
  mutexUse.getEnclosingFunction() = func and
  owningObject = mutexUse.getOwningObject() and
  not exists(ThreadObjectInitialization init |
    init.getEnclosingFunction() = func and
    init.getOwningObject() = owningObject and
    mutexUse.getAPredecessor+() = init
  )
  or
  exists(FunctionCall call |
    func = call.getEnclosingFunction() and
    requiresInitializedMutexObject(call.getTarget(), mutexUse, owningObject) and
    not exists(ThreadObjectInitialization init |
      call.getAPredecessor*() = init and
      init.getOwningObject() = owningObject
    )
  )
  or
  exists(C11ThreadCreateCall call |
    func = call.getEnclosingFunction() and
    not owningObject.getStorageDuration().isThread() and
    requiresInitializedMutexObject(call.getFunction(), mutexUse, owningObject) and
    not exists(ThreadObjectInitialization init |
      call.getAPredecessor*() = init and
      init.getOwningObject() = owningObject
    )
  )
}

from ThreadObjectUse objUse, ObjectIdentity obj, Function callRoot
where
  not isExcluded(objUse, Concurrency8Package::mutexNotInitializedBeforeUseQuery()) and
  obj = objUse.getOwningObject() and
  requiresInitializedMutexObject(callRoot, objUse, obj) and
  (
    if obj.getStorageDuration().isAutomatic()
    then obj.getEnclosingElement+() = callRoot
    else (
      obj.getStorageDuration().isThread() and callRoot instanceof ThreadedFunction
      or
      callRoot instanceof RootFunction
    )
  )
select objUse,
  objUse.getDescription() +
    " '$@' possibly used before initialization, from entry point function '$@'.", obj,
  obj.toString(), callRoot, callRoot.getName()

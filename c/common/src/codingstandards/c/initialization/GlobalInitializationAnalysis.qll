import cpp
import codingstandards.c.Objects
import codingstandards.cpp.Concurrency
import codingstandards.cpp.Type

signature module GlobalInitializationAnalysisConfigSig {
  /** A function which is not called or started as a thread */
  default predicate isRootFunction(Function f) {
    not exists(Function f2 | f2.calls(f)) and
    not f instanceof ThreadedFunction and
    // Exclude functions which are used as function pointers.
    not exists(FunctionAccess access | f = access.getTarget())
  }

  ObjectIdentity getAnInitializedObject(Expr e);

  ObjectIdentity getAUsedObject(Expr e);
}

module GlobalInitalizationAnalysis<GlobalInitializationAnalysisConfigSig Config> {
  final class FinalFunction = Function;

  final class FinalExpr = Expr;

  class RootFunction extends FinalFunction {
    RootFunction() { Config::isRootFunction(this) }
  }

  /** A function call which initializes a mutex or a condition */
  class ObjectInit extends FinalExpr {
    ObjectIdentity owningObject;

    ObjectInit() { owningObject = Config::getAnInitializedObject(this) }

    ObjectIdentity getOwningObject() { result = owningObject }
  }

  /**
   * A function argument where that argument is used as a mutex or condition object.
   */
  class ObjectUse extends FinalExpr {
    ObjectIdentity owningObject;

    ObjectUse() { owningObject = Config::getAUsedObject(this) }

    ObjectIdentity getOwningObject() { result = owningObject }
  }

  predicate requiresInitializedMutexObject(
    Function func, ObjectUse mutexUse, ObjectIdentity owningObject
  ) {
    mutexUse.getEnclosingFunction() = func and
    owningObject = mutexUse.getOwningObject() and
    not exists(ObjectInit init |
      init.getEnclosingFunction() = func and
      init.getOwningObject() = owningObject and
      mutexUse.getAPredecessor+() = init
    )
    or
    exists(FunctionCall call |
      func = call.getEnclosingFunction() and
      requiresInitializedMutexObject(call.getTarget(), mutexUse, owningObject) and
      not exists(ObjectInit init |
        call.getAPredecessor*() = init and
        init.getOwningObject() = owningObject
      )
    )
    or
    exists(C11ThreadCreateCall call |
      func = call.getEnclosingFunction() and
      not owningObject.getStorageDuration().isThread() and
      requiresInitializedMutexObject(call.getFunction(), mutexUse, owningObject) and
      not exists(ObjectInit init |
        call.getAPredecessor*() = init and
        init.getOwningObject() = owningObject
      )
    )
  }

  predicate uninitializedFrom(Expr e, ObjectIdentity obj, Function callRoot) {
    exists(ObjectUse use | use = e |
      obj = use.getOwningObject() and
      requiresInitializedMutexObject(callRoot, use, obj) and
      (
        if obj.getStorageDuration().isAutomatic()
        then obj.getEnclosingElement+() = callRoot
        else (
          obj.getStorageDuration().isThread() and callRoot instanceof ThreadedFunction
          or
          callRoot instanceof RootFunction
        )
      )
    )
  }
}

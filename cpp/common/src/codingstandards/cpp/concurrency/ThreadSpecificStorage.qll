import cpp
private import semmle.code.cpp.dataflow.DataFlow
private import codingstandards.cpp.concurrency.ThreadCreation

/**
 * Models calls to thread specific storage function calls.
 */
abstract class ThreadSpecificStorageFunctionCall extends FunctionCall {
  /**
   * Gets the key to which this call references.
   */
  Expr getKey() { getArgument(0) = result }
}

/**
 * Models calls to `tss_get`.
 */
class TSSGetFunctionCall extends ThreadSpecificStorageFunctionCall {
  TSSGetFunctionCall() { getTarget().getName() = "tss_get" }
}

/**
 * Models calls to `tss_set`.
 */
class TSSSetFunctionCall extends ThreadSpecificStorageFunctionCall {
  TSSSetFunctionCall() { getTarget().getName() = "tss_set" }
}

/**
 * Models calls to `tss_create`
 */
class TSSCreateFunctionCall extends ThreadSpecificStorageFunctionCall {
  TSSCreateFunctionCall() { getTarget().getName() = "tss_create" }

  predicate hasDeallocator() {
    not exists(MacroInvocation mi, NullMacro nm |
      getArgument(1) = mi.getExpr() and
      mi = nm.getAnInvocation()
    )
  }
}

/**
 * Models calls to `tss_delete`
 */
class TSSDeleteFunctionCall extends ThreadSpecificStorageFunctionCall {
  TSSDeleteFunctionCall() { getTarget().getName() = "tss_delete" }
}

/**
 * Gets a call to `DeallocationExpr` that deallocates memory owned by thread specific
 * storage.
 */
predicate getAThreadSpecificStorageDeallocationCall(C11ThreadCreateCall tcc, DeallocationExpr dexp) {
  exists(TSSGetFunctionCall tsg |
    tcc.getFunction().getEntryPoint().getASuccessor*() = tsg and
    DataFlow::localFlow(DataFlow::exprNode(tsg), DataFlow::exprNode(dexp.getFreedExpr()))
  )
}

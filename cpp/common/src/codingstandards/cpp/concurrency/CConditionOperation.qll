import cpp

/**
 * Models a function which uses a c condition variable. Not integrated into the thread aware CFG.
 */
class CConditionOperation extends FunctionCall {
  CConditionOperation() {
    getTarget().hasName(["cnd_broadcast", "cnd_signal", "cnd_timedwait", "cnd_wait", "cnd_init"])
  }

  predicate isInit() { getTarget().hasName("cnd_init") }

  predicate isUse() { not isInit() }

  Expr getConditionExpr() { result = getArgument(0) }

  /* Note: only holds for `cnd_wait()` and `cnd_timedwait()` */
  Expr getMutexExpr() { result = getArgument(1) }
}

/**
 * Models C style condition destruction via `cnd_destroy`.
 */
class C11ConditionDestroyer extends FunctionCall {
  C11ConditionDestroyer() { getTarget().getName() = "cnd_destroy" }

  /**
   * Returns the `Expr` being destroyed.
   */
  Expr getConditionExpr() { result = getArgument(0) }
}

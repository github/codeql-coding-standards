/** Provides the exit detector shared by Advisory and Disapplied query wrappers. */

import cpp

/** A return statement explicitly written in source code. */
private class UserReturn extends ReturnStmt {
  UserReturn() { not this.isCompilerGenerated() }
}

/** Holds if `function` has an offending `statement`, with `message` explaining why. */
predicate problems(Function function, string message, ReturnStmt statement) {
  function.hasDefinition() and
  count(function.getBlock()) = 1 and
  not function.isCompilerGenerated() and
  statement instanceof UserReturn and
  statement.getEnclosingFunction() = function and
  (
    count(UserReturn other | other.getEnclosingFunction() = function) > 1 and
    message = "Function has more than one $@."
    or
    count(UserReturn other | other.getEnclosingFunction() = function) = 1 and
    not function.getBlock().getLastStmt() instanceof UserReturn and
    message = "The $@ is not the last statement of the function."
  )
}

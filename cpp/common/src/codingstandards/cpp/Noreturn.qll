import cpp

/**
 * A function marked with _Noreturn or __attribute((noreturn))
 */
class NoreturnFunction extends Function {
  NoreturnFunction() {
    this.getASpecifier().getName() = "noreturn" or
    this.getAnAttribute().getName() = "noreturn"
  }
}

/**
 * A function that may complete normally, and/or contains an explicit reachable
 * return statement.
 */
predicate mayReturn(Function function) {
  exists(ReturnStmt s |
    function = s.getEnclosingFunction() and
    s.getBasicBlock().isReachable()
  )
}

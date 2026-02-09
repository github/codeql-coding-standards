import cpp

/**
 * An lvalue in C (as opposed to C++).
 *
 * Note that `Expr.isLValue()` matches for C++ lvalues, which is a larger set
 * than the set of C lvalues.
 */
predicate isCLValue(Expr expr) {
  expr instanceof PointerFieldAccess
  or
  expr.isLValue() and
  not expr instanceof ConditionalExpr and
  not expr instanceof AssignExpr and
  not expr instanceof CommaExpr and
  not exists(Cast c | c = expr.getConversion*())
  or
  // 6.5.2.5.4: Compound literals are always lvalues.
  expr instanceof AggregateLiteral
}

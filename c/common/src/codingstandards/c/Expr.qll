import cpp

/* A full expression as defined in ISO/IEC 9899:2011 Annex C point 1. */
class FullExpr extends Expr {
  FullExpr() {
    // An initializer that is not part of a compound literal (see 6.7.9).
    this instanceof AssignExpr and not this.getParent+() instanceof AggregateLiteral
    or
    // The expression in an expression statement (see 6.8.3)
    any(ExprStmt s).getExpr() = this
    or
    // The controlling expression of a selection statement (see 6.8.4) or
    // the controlling expression of a `while`, `do`, or `for` statement (see 6.8.5)
    any(ControlStructure s).getControllingExpr() = this
    or
    // Each of the possible optional expressions, besides the controlling expression,
    // of a `for` statement (see 6.8.5.3). Note that if `clause-1` will be an expression statement if
    // it is an expression and is therefore handle in the expression statement case.
    any(ForStmt s).getUpdate() = this
    or
    // The expression in a `return` statement, if any (see 6.8.6.4)
    any(ReturnStmt s).getExpr() = this
  }
}

/* A constituent expression is a sub-expression of a full expression. */
class ConstituentExpr extends Expr {
  ConstituentExpr() { not this instanceof FullExpr }

  FullExpr getFullExpr() { result = this.getParent+() }
}

/* A primary expression as defined in ISO/IEC 9899:201x 6.5.1 */
class PrimaryExpr extends Expr {
  PrimaryExpr() {
    exists(VariableAccess va | va.isLValue() and this = va)
    or
    exists(Literal l | this = l)
    or
    this.isParenthesised()
    // or a generic selection _Generic that is a compile time evaluated
    // expression that we can't model because of missing support.
  }
}

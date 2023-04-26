import cpp

/* A full expression as defined in ISO/IEC 9899:2011 6.8 point 4 and Annex C point 1 item 5. */
class FullExpr extends Expr {
  FullExpr() {
    exists(ExprStmt s | this = s.getExpr())
    or
    exists(Loop l | this = l.getControllingExpr())
    or
    exists(ConditionalStmt s | this = s.getControllingExpr())
    or
    exists(ForStmt s | this = s.getUpdate())
    or
    exists(ReturnStmt s | this = s.getExpr())
    or
    this instanceof AggregateLiteral
    or
    this = any(Variable v).getInitializer().getExpr()
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

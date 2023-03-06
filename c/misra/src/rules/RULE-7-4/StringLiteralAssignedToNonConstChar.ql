/**
 * @id c/misra/string-literal-assigned-to-non-const-char
 * @name RULE-7-4: A string literal shall only be assigned to a pointer to const char
 * @description Assigning string literal to a variable with type other than a pointer to const char
 *              and modifying it causes undefined behavior .
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

class NonConstCharStarType extends Type {
  NonConstCharStarType() {
    this instanceof CharPointerType and
    not this.isDeeplyConstBelow()
  }
}

/* A non-const-char* variable declared with a string literal */
predicate declaringNonConstCharVar(Variable decl, string message) {
  not decl instanceof Parameter and // exclude parameters
  /* It should be declaring a char* type variable */
  decl.getUnspecifiedType() instanceof CharPointerType and
  not decl.getUnderlyingType().isDeeplyConstBelow() and
  /* But it's declared to hold a string literal.  */
  decl.getInitializer().getExpr() instanceof StringLiteral and
  message = "char* variable " + decl + " is declared with a string literal."
}

/* String literal being assigned to a non-const-char* variable */
predicate assignmentToNonConstCharVar(Assignment assign, string message) {
  /* The variable being assigned is char* */
  assign.getLValue().getUnderlyingType() instanceof NonConstCharStarType and
  /* But the rvalue is a string literal */
  exists(Expr rvalue | rvalue = assign.getRValue() | rvalue instanceof StringLiteral) and
  message = "char* variable " + assign.getLValue() + " is assigned a string literal. "
}

/* String literal being passed to a non-const-char* parameter */
predicate assignmentToNonConstCharParam(FunctionCall call, string message) {
  exists(int index |
    /* Param at index is a char* */
    call.getTarget().getParameter(index).getUnderlyingType() instanceof NonConstCharStarType and
    /* But a string literal is passed */
    call.getArgument(index) instanceof StringLiteral
  ) and
  message = "char* parameter of " + call.getTarget() + " is passed a string literal."
}

/* String literal being returned by a non-const-char* function */
predicate returningNonConstCharVar(ReturnStmt return, string message) {
  /* The function is declared to return a char* */
  return.getEnclosingFunction().getType().resolveTypedefs() instanceof NonConstCharStarType and
  /* But in reality it returns a string literal */
  return.getExpr() instanceof StringLiteral and
  message = "char* function " + return.getEnclosingFunction() + " is returning a string literal."
}

from Element elem, string message
where
  not isExcluded(elem, TypesPackage::stringLiteralAssignedToNonConstCharQuery()) and
  (
    declaringNonConstCharVar(elem, message)
    or
    assignmentToNonConstCharVar(elem, message)
    or
    assignmentToNonConstCharParam(elem, message)
    or
    returningNonConstCharVar(elem, message)
  )
select elem, message

/**
 * @id c/misra/string-literal-assigned-to-non-const-char
 * @name RULE-7-4: A string literal shall only be assigned to a pointer to const char.
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
predicate declaringNonConstCharVar(Variable decl) {
  not decl instanceof Parameter and // exclude parameters
  /* It should be declaring a char* type variable */
  decl.getUnspecifiedType() instanceof CharPointerType and
  not decl.getUnderlyingType().isDeeplyConstBelow() and
  /* But it's declared to hold a string literal.  */
  decl.getInitializer().getExpr() instanceof StringLiteral
}

/* String literal being assigned to a non-const-char* variable */
predicate assignmentToNonConstCharVar(Assignment assign) {
  /* The variable being assigned is char* */
  assign.getLValue().getUnderlyingType() instanceof NonConstCharStarType and
  /* But the rvalue is a string literal */
  exists(Expr rvalue | rvalue = assign.getRValue() | rvalue instanceof StringLiteral)
}

/* String literal being passed to a non-const-char* parameter */
predicate assignmentToNonConstCharParam(FunctionCall call) {
  exists(int index |
    /* Param at index is a char* */
    call.getTarget().getParameter(index).getUnderlyingType() instanceof NonConstCharStarType and
    /* But a string literal is passed */
    call.getArgument(index) instanceof StringLiteral
  )
}

/* String literal being returned by a non-const-char* function */
predicate returningNonConstCharVar(ReturnStmt return) {
  /* The function is declared to return a char* */
  return.getEnclosingFunction().getType().resolveTypedefs() instanceof NonConstCharStarType and
  /* But in reality it returns a string literal */
  return.getExpr() instanceof StringLiteral
}

// newtype TProblematicElem =
//   TVar(Variable decl) or
//   TAssign(Assignment assign) or
//   TFunCall(FunctionCall call) or
//   TReturnStmt(ReturnStmt return)
// class ProblematicElem extends TProblematicElem {
//   Variable getVariable() { this = TVar(result) }
//   Assignment getAssign() { this = TAssign(result) }
//   FunctionCall getFunCall() { this = TFunCall(result) }
//   ReturnStmt getReturnStmt() { this = TReturnStmt(result) }
//   override string toString() {
//     this instanceof TVar and result = this.getVariable().toString()
//     or
//     this instanceof TAssign and result = this.getAssign().toString()
//     or
//     this instanceof TFunCall and result = this.getFunCall().toString()
//     or
//     this instanceof TReturnStmt and result = this.getReturnStmt().toString()
//   }
// }
// class ProblematicElem = Variable or Assignment or FunctionCall or ReturnStmt;
// ^ Nope!
from Variable decl, Assignment assign, FunctionCall call, ReturnStmt return, string message
where
  not isExcluded(decl, TypesPackage::stringLiteralAssignedToNonConstCharQuery()) and
  not isExcluded(assign, TypesPackage::stringLiteralAssignedToNonConstCharQuery()) and
  not isExcluded(call, TypesPackage::stringLiteralAssignedToNonConstCharQuery()) and
  not isExcluded(return, TypesPackage::stringLiteralAssignedToNonConstCharQuery()) and
  (
    declaringNonConstCharVar(decl) and
    message = "char* variable " + decl + " is declared with a string literal."
    or
    assignmentToNonConstCharVar(assign) and
    message = "char* variable " + assign.getLValue() + " is assigned a string literal. "
    or
    assignmentToNonConstCharParam(call) and
    message = "char* parameter of " + call.getTarget() + " is passed a string literal."
    or
    returningNonConstCharVar(return) and
    message = "char* function " + return.getEnclosingFunction() + " is returning a string literal."
  )
select message

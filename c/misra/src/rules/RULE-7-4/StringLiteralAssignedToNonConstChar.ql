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

/** Pointer to Wide character type, i.e. `wchar_t*`. */
class WideCharPointerType extends PointerType {
  WideCharPointerType() { this.getBaseType() instanceof Wchar_t }

  override string getAPrimaryQlClass() { result = "WideCharPointerType" }
}

class GenericCharPointerType extends Type {
  GenericCharPointerType() {
    // A wide char pointer type
    this instanceof WideCharPointerType
    or
    // A char pointer type
    this.getUnspecifiedType() instanceof CharPointerType
    or
    // A typedef to any such type.
    // Note: wchar_t is usually a typedef, so we cannot just use getUnspecifiedType() here.
    this.(TypedefType).getBaseType() instanceof GenericCharPointerType
  }
}

class NonConstCharStarType extends Type {
  NonConstCharStarType() {
    this instanceof GenericCharPointerType and
    not this.isDeeplyConstBelow()
  }
}

/* A non-const-char* variable declared with a string literal */
predicate declaringNonConstCharVar(Variable decl, string message) {
  not decl instanceof Parameter and // exclude parameters
  /* It should be declaring a char* type variable */
  decl.getType() instanceof NonConstCharStarType and
  /* But it's declared to hold a string literal. */
  decl.getInitializer().getExpr() instanceof StringLiteral and
  message =
    decl.getType().(GenericCharPointerType) + " variable " + decl +
      " is declared with a string literal."
}

/* String literal being assigned to a non-const-char* variable */
predicate assignmentToNonConstCharVar(Assignment assign, string message) {
  /* The variable being assigned is char* */
  assign.getLValue().getType() instanceof NonConstCharStarType and
  /* But the rvalue is a string literal */
  assign.getRValue() instanceof StringLiteral and
  message =
    assign.getLValue().getType().(GenericCharPointerType) + " variable " + assign.getLValue() +
      " is assigned a string literal. "
}

/* String literal being passed to a non-const-char* parameter */
predicate assignmentToNonConstCharParam(FunctionCall call, string message) {
  exists(int index |
    /* Param at index is a char* */
    call.getTarget().getParameter(index).getType() instanceof NonConstCharStarType and
    /* But a string literal is passed */
    call.getArgument(index) instanceof StringLiteral and
    message =
      call.getTarget().getParameter(index).getType().(GenericCharPointerType) + " parameter of " +
        call.getTarget() + " is passed a string literal."
  )
}

/* String literal being returned by a non-const-char* function */
predicate returningNonConstCharVar(ReturnStmt return, string message) {
  /* The function is declared to return a char* */
  return.getEnclosingFunction().getType() instanceof NonConstCharStarType and
  /* But in reality it returns a string literal */
  return.getExpr() instanceof StringLiteral and
  message =
    return.getEnclosingFunction().getType().(GenericCharPointerType) + " function " +
      return.getEnclosingFunction() + " is returning a string literal."
}

from Element elem, string message
where
  not isExcluded(elem, Types1Package::stringLiteralAssignedToNonConstCharQuery()) and
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

/**
 * @id cpp/autosar/gratuitous-use-of-parentheses
 * @name M5-0-2: Limited dependence should be placed on C++ operator precedence rules in expressions
 * @description The use of parentheses should be used to override or emphasize operator precedence.
 *              However, gratuitous use of parentheses can decrease code readability.
 * @kind problem
 * @precision medium
 * @problem.severity recommendation
 * @tags external/autosar/id/m5-0-2
 *       external/autosar/audit
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

abstract class AcceptableParenthesisExpr extends ParenthesisExpr { }

private class DefaultAcceptableParenthesisExpr extends AcceptableParenthesisExpr {
  DefaultAcceptableParenthesisExpr() {
    // Allow calls through pointers to be surrounded by parentheses.
    exists(ExprCall call | call.getExpr() = this.getExpr())
    or
    // Allow pointer dereferences to be surrounded by parentheses.
    // That is, allow `(*ptr)[i]` expressions
    this.getExpr() instanceof PointerDereferenceExpr
    or
    // Allow expression being casted to be s surrounded by parentheses.
    // That is, allow `(char) (n+1)`
    exists(Cast cast | cast.getExpr() = this)
  }
}

private predicate isTopMostBinaryOperation(BinaryOperation binop) {
  not exists(BinaryOperation other | other.getAnOperand().getAChild*() = binop)
}

private BinaryOperation getTopMostBinaryOperation(BinaryOperation binop) {
  result = binop.getParent*() and isTopMostBinaryOperation(result)
}

/** Holds if all the binary operations part of `binop` have the same operator */
private predicate isHomogeneousBinaryOperation(BinaryOperation binop) {
  forall(BinaryOperation child | child = binop.getAChild*() |
    child.getOperator() = binop.getOperator()
  )
}

predicate isGratuitousUseOfParentheses(ParenthesisExpr pe) {
  not pe instanceof AcceptableParenthesisExpr and
  (
    // Parentheses are not required for the right-hand operand of an assignment unless the right-hand
    // itself contains an assignment expression
    exists(Assignment assignment |
      pe.getExpr() = assignment.getRValue() and not pe.getExpr() instanceof Assignment
    )
    or
    // Parentheses are not required for binary and ternary operators if all the operatores are equal
    // and their operand types are equal.
    exists(BinaryArithmeticOperation parent, BinaryArithmeticOperation binop, Expr otherOperand |
      isHomogeneousBinaryOperation(getTopMostBinaryOperation(parent)) and
      parent.getAnOperand() = binop and
      binop = pe.getExpr() and
      otherOperand = parent.getAnOperand() and
      not otherOperand = binop
    |
      binop.getAnOperand().getUnconverted().getUnspecifiedType() = otherOperand.getUnspecifiedType() and
      binop.getLeftOperand().getUnconverted().getUnspecifiedType() =
        binop.getRightOperand().getUnconverted().getUnspecifiedType()
    )
    or
    // Parentheses are not required for the operand of a unary operation
    exists(UnaryOperation unop | pe.getExpr() = unop)
    or
    // Parentheses are not required for access of operands
    exists(BinaryOperation binop, Access access | binop.getAnOperand() = access |
      pe.getExpr() = access
    )
  )
}

from ParenthesisExpr p
where
  not isExcluded(p) and
  isGratuitousUseOfParentheses(p) and
  not p.isInMacroExpansion()
select p, "Gratuitous use of parentheses around $@.", p.getExpr(), p.getExpr().toString()

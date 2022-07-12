/**
 * @id c/misra/implicit-precedence-of-operators-in-expression
 * @name RULE-12-1: The precedence of operators within expressions should be made explicit
 * @description The relative precedences of operators are not intuitive and can lead to mistakes.
 *              The use of parentheses to make the precedence of operators explicit removes the
 *              possibility of incorrect expectations.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-12-1
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Expr

int getPrecedence(Expr e) {
  e instanceof PrimaryExpr and result = 16
  or
  (
    e instanceof PostfixCrementOperation
    or
    e instanceof ClassAggregateLiteral
    or
    e instanceof ArrayExpr
    or
    e instanceof FunctionCall
    or
    e instanceof DotFieldAccess
    or
    e instanceof PointerFieldAccess
  ) and
  result = 15
  or
  (
    e instanceof PrefixCrementOperation
    or
    e instanceof AddressOfExpr
    or
    e instanceof PointerDereferenceExpr
    or
    e instanceof UnaryPlusExpr
    or
    e instanceof UnaryMinusExpr
    or
    e instanceof ComplementExpr
    or
    e instanceof NotExpr
    or
    e instanceof SizeofOperator
    or
    e instanceof AlignofOperator
  ) and
  result = 14
  or
  e instanceof Cast and result = 13
  or
  (
    e instanceof MulExpr
    or
    e instanceof DivExpr
    or
    e instanceof RemExpr
  ) and
  result = 12
  or
  (
    e instanceof AddExpr
    or
    e instanceof SubExpr
  ) and
  result = 11
  or
  (
    e instanceof LShiftExpr
    or
    e instanceof RShiftExpr
  ) and
  result = 10
  or
  e instanceof RelationalOperation and result = 9
  or
  e instanceof EqualityOperation and result = 8
  or
  e instanceof BitwiseAndExpr and result = 7
  or
  e instanceof BitwiseXorExpr and result = 6
  or
  e instanceof BitwiseOrExpr and result = 5
  or
  e instanceof LogicalAndExpr and result = 4
  or
  e instanceof LogicalOrExpr and result = 3
  or
  e instanceof ConditionalExpr and result = 2
  or
  e instanceof Assignment and result = 1
  or
  e instanceof CommaExpr and result = 0
}

from Expr e, Expr operand
where
  not isExcluded(e, SideEffects1Package::implicitPrecedenceOfOperatorsInExpressionQuery()) and
  getPrecedence(e) in [2 .. 12] and
  e.getAChild() = operand and
  getPrecedence(operand) > getPrecedence(e) and
  getPrecedence(operand) < 13 and
  (
    if operand instanceof SizeofExprOperator
    then not operand.(SizeofExprOperator).getExprOperand().isParenthesised()
    else not operand.isParenthesised()
  ) and
  // Exclude the requirement for (v), (1), ("foo"), or macro calls like `assert(x==y)` that can be expanded to `x == y ? ... : ...`
  not (
    operand instanceof VariableAccess or
    operand instanceof Literal or
    e.isInMacroExpansion()
  )
select e, "Operand $@ is not enclosed by parentheses.", operand, operand.toString()

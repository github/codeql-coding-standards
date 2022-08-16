/**
 * @id c/cert/do-not-use-a-bitwise-operator-with-a-boolean-like-operand
 * @name EXP46-C: Do not use a bitwise operator with a Boolean-like operand
 * @description Using bitwise operators with unparenthesized Boolean-like operands may indicate a
 *              logic error.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp46-c
 *       maintainability
 *       readability
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

/**
 * Holds if `op` is a bitwise AND, OR, or XOR expression
 */
predicate isBitwiseOperationPotentiallyAmbiguous(BinaryBitwiseOperation op) {
  op instanceof BitwiseAndExpr or
  op instanceof BitwiseOrExpr or
  op instanceof BitwiseXorExpr
}

/**
 * Holds if `e` is an unparenthesised boolean expression,
 * relational operation, or equality operation.
 */
predicate isDisallowedBitwiseOperationOperand(Expr e) {
  not e.isParenthesised() and
  (
    e.getFullyConverted().getUnderlyingType() instanceof BoolType or
    e instanceof RelationalOperation or
    e instanceof EqualityOperation
  )
}

from Expr operand, Operation operation
where
  not isExcluded(operation,
    ExpressionsPackage::doNotUseABitwiseOperatorWithABooleanLikeOperandQuery()) and
  isBitwiseOperationPotentiallyAmbiguous(operation) and
  operand = operation.getAnOperand() and
  isDisallowedBitwiseOperationOperand(operand)
select operation,
  "Bitwise operator " + operation.getOperator() +
    " performs potentially unintended operation on $@.", operand, "boolean operand"

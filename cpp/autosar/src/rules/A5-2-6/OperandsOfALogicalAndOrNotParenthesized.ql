/**
 * @id cpp/autosar/operands-of-a-logical-and-or-not-parenthesized
 * @name A5-2-6: The operands of a logical && or || shall be parenthesized if the operands contain binary operators
 * @description The operands of a logical && or || shall be parenthesized if the operands contain
 *              binary operators to make the expressions more readable.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a5-2-6
 *       correctness
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from BinaryLogicalOperation op, Expr operand
where
  not isExcluded(op, OrderOfEvaluationPackage::operandsOfALogicalAndOrNotParenthesizedQuery()) and
  operand = op.getAnOperand() and
  /* The operand is a built-in arithmetic/logic binary operation */
  if operand instanceof BinaryOperation
  then
    not exists(ParenthesisExpr p | p = operand.getFullyConverted()) and
    // Exclude binary operations expanded by a macro.
    not operand.isInMacroExpansion()
  else
    /* The operand should not be a field access operation */
    not operand instanceof FieldAccess
select op, "Binary $@ operand of logical operation is not parenthesized.", operand, "operator"

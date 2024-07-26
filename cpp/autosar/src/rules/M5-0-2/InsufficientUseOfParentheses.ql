/**
 * @id cpp/autosar/insufficient-use-of-parentheses
 * @name M5-0-2: Limited dependence should be placed on C++ operator precedence rules in expressions
 * @description The use of parentheses can be used to emphasize precedence and increase code
 *              readability.
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
import semmle.code.cpp.commons.Assertions

class InsufficientlyParenthesizedExpr extends Expr {
  InsufficientlyParenthesizedExpr() {
    // Exclude expressions affected by macros, including assertions, because
    // it is unclear that the expression must be parenthesized since it seems
    // to be the top-level expression instead of an operand of a binary or ternary operation.
    not this.isAffectedByMacro() and
    (
      exists(BinaryOperation root, BinaryOperation child | child = this |
        root.getAnOperand() = child and
        root.getOperator() != child.getOperator() and
        not any(ParenthesisExpr pe).getExpr() = child
      )
      or
      exists(ConditionalExpr root, BinaryOperation child | child = this |
        root.getAnOperand() = child and
        not any(ParenthesisExpr pe).getExpr() = child
      )
    )
  }
}

from InsufficientlyParenthesizedExpr e
where not isExcluded(e, OrderOfEvaluationPackage::insufficientUseOfParenthesesQuery())
select e, "Dependence on operator precedence rules."

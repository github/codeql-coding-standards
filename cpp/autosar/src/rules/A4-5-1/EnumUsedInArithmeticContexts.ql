/**
 * @id cpp/autosar/enum-used-in-arithmetic-contexts
 * @name A4-5-1: Enums shall not be used in arithmetic contexts
 * @description Expressions with type enum or enum class shall not be used as operands to built-in
 *              and overloaded operators other than the subscript operator [], the assignment
 *              operator =, the equality operators == and ! =, the unary & operator, and the
 *              relational operators <, <=, >, >=.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a4-5-1
 *       correctness
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/*
 * Get an operand to all overloaded operator member functions, except:
 *   operator[]
 *   operator=
 *   operator==
 *   operator!=
 *   operator&
 *   operator<
 *   operator<=
 *   operator>
 *   operator>=
 */

Expr getAnOperandOfAllowedOverloadedOperator(FunctionCall fc) {
  fc.getAnArgument() = result and
  fc.getTarget().getName().regexpMatch("operator(?!\\[]$|=$|==$|!=$|&$|<$|<=$|>$|>=$).+")
}

Expr getAnOperandOfAllowedOperation(Operation o) {
  o.getAnOperand() = result and
  not (
    o instanceof AssignExpr or
    o instanceof BitwiseAndExpr or
    o instanceof ComparisonOperation
  )
}

from Expr e, Expr operand
where
  not isExcluded(e, ExpressionsPackage::enumUsedInArithmeticContextsQuery()) and
  (
    operand = getAnOperandOfAllowedOverloadedOperator(e)
    or
    operand = getAnOperandOfAllowedOperation(e)
  ) and
  (
    operand instanceof EnumConstantAccess or
    operand.(VariableAccess).getType() instanceof Enum
  )
select e, "Enum $@ is used as an operand of arithmetic operation.", operand, "expression"

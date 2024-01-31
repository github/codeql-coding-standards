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
import codingstandards.cpp.Operator

class AllowedOperatorUse extends OperatorUse {
  AllowedOperatorUse() {
    this.getOperator() in ["[]", "=", "==", "!=", "<", "<=", ">", ">="]
    or
    this.(UnaryOperatorUse).getOperator() = "&" 
  }
}

from OperatorUse operatorUse, Access access, Enum enum 
where
  not isExcluded(access, ExpressionsPackage::enumUsedInArithmeticContextsQuery()) and
  operatorUse.getAnOperand() = access and
  (
    access.(EnumConstantAccess).getTarget().getDeclaringEnum() = enum or
    access.(VariableAccess).getType() = enum 
  ) and
  not operatorUse instanceof AllowedOperatorUse
select access, "Enum $@ is used as an operand of arithmetic operation.", enum, enum.getName()

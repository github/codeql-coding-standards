/**
 * @id cpp/autosar/bool-operands-to-disallowed-built-in-operators
 * @name M4-5-1: Expressions with type bool shall only be used as operands to =, &&, ||, !, ==, !=, &, and ?:
 * @description The use of bool operands with other operators is unlikely to be meaningful (or
 *              intended). This rule allows the detection of such uses, which often occur because
 *              the logical operators (&&, || and !) can be easily confused with the bitwise
 *              operators (&, | and ~).
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m4-5-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Operation o
where
  o.getAnOperand().getType() instanceof BoolType and
  not (
    o instanceof AssignExpr or
    o instanceof LogicalAndExpr or
    o instanceof LogicalOrExpr or
    o instanceof NotExpr or
    o instanceof EqualityOperation or
    o instanceof BitwiseAndExpr or
    o instanceof ConditionalExpr
  )
select o, "Operand to operator '" + o.getOperator() + "' does not have type 'bool'."

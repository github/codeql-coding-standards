/**
 * @id cpp/autosar/char-used-as-operands-to-disallowed-built-in-operators
 * @name M4-5-3: Expressions with type (plain) char and wchar_t shall only be used as operands to =, ==, !=, &
 * @description Expressions with type (plain) char and wchar_t shall not be used as operands to
 *              built-in operators other than the assignment operator =, the equality operators ==
 *              and ! =, and the unary & operator. Manipulation of character data may generate
 *              results that are contrary to developer expectations. For example, ISO/IEC 14882:2003
 *              [1] §2.2(3) only requires that the digits "0" to "9" have consecutive numerical
 *              values.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m4-5-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Operation o
where
  not isExcluded(o) and
  not (
    o instanceof EqualityOperation or
    o instanceof BitwiseAndExpr or
    o instanceof AssignExpr
  ) and
  (
    o.getAnOperand().getType() instanceof CharType
    or
    o.getAnOperand().getType() instanceof Wchar_t
  )
select o, "Operand to operator '" + o.getOperator() + "' has character type."

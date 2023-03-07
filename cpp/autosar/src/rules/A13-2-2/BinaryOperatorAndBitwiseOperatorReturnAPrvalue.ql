/**
 * @id cpp/autosar/binary-operator-and-bitwise-operator-return-a-prvalue
 * @name A13-2-2: A binary arithmetic operator and a bitwise operator shall return a 'prvalue'
 * @description A binary arithmetic operator and a bitwise operator shall return a 'prvalue'.
 *              Returning a type T from binary arithmetic and bitwise operators is consistent with
 *              the C++ Standard Library.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a13-2-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator
import semmle.code.cpp.Print

from Operator o
where
  not isExcluded(o, OperatorInvariantsPackage::binaryOperatorAndBitwiseOperatorReturnAPrvalueQuery()) and
  (o instanceof UserBitwiseOperator or o instanceof UserArithmeticOperator) and
  (
    o.getType().isDeeplyConst()
    or
    o.getType() instanceof PointerType
    or
    o.getType() instanceof ReferenceType
  )
select o,
  "User-defined bitwise or arithmetic operator " + getIdentityString(o) +
    " does not return a prvalue."

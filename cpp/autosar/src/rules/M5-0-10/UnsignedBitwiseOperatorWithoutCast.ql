/**
 * @id cpp/autosar/unsigned-bitwise-operator-without-cast
 * @name M5-0-10: If the bitwise operators ~and << are applied to an operand with an underlying type of unsigned char
 * @description If the bitwise operators ~and << are applied to an operand with an underlying type
 *              of unsigned char or unsigned short, the result shall be immediately cast to the
 *              underlying type of the operand.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-0-10
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Expr e, Type underlying
where
  not isExcluded(e, OperatorsPackage::unsignedBitwiseOperatorWithoutCastQuery()) and
  (e instanceof ComplementExpr or e instanceof LShiftExpr) and
  (underlying instanceof UnsignedCharType or underlying.(ShortType).isUnsigned()) and
  not e.getConversion().getType().getUnderlyingType() = underlying and
  underlying = e.getChild(0).getExplicitlyConverted().getType().getUnderlyingType()
select e,
  "Unsigned bitwise operation result is not immediately cast to the underlying type of the operand."

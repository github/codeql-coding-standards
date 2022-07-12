/**
 * @id cpp/autosar/implicit-const-floating-integral-conversion
 * @name M5-0-5: There shall be no implicit floating-integral conversions
 * @description There shall be no implicit floating-integral conversions, because such a conversion
 *              might not be value preserving and may lead to undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-0-5
 *       correctness
 *       external/autosar/strict
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Conversion

from FloatingIntegralConversion c
where
  not isExcluded(c, IntegerConversionPackage::implicitConstFloatingIntegralConversionQuery()) and
  c.isImplicit() and
  c.isConstant()
select c, "Implicit conversion of constant $@ from " + c.getDirection() + ".", c.getExpr(),
  c.getDescription()

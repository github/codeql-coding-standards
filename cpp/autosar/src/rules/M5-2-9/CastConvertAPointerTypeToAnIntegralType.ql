/**
 * @id cpp/autosar/cast-convert-a-pointer-type-to-an-integral-type
 * @name M5-2-9: A cast shall not convert a pointer type to an integral type
 * @description A cast shall not convert a pointer type to an integral type, because the size of an
 *              integral type is implementation defined.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-2-9
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Cast c
where
  not isExcluded(c, PointersPackage::castConvertAPointerTypeToAnIntegralTypeQuery()) and
  not c.isImplicit() and
  c.getExpr().getType() instanceof PointerType and
  c.getType() instanceof IntegralType
select c, "Cast converts an object of pointer type to an integral type."

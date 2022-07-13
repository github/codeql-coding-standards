/**
 * @id cpp/autosar/integer-or-pointer-to-void-converted-to-pointer-type
 * @name M5-2-8: An object with integer type or pointer to void type shall not be converted to an object with pointer type
 * @description An object with integer type or pointer to void type shall not be converted to an
 *              object with pointer type, because it can lead to unspecified behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-2-8
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Cast c, Type t, string type
where
  not isExcluded(c, PointersPackage::integerOrPointerToVoidConvertedToPointerTypeQuery()) and
  not c.isImplicit() and
  not c.isAffectedByMacro() and
  t = c.getExpr().getType() and
  (
    t instanceof IntegralType and type = "integer"
    or
    t instanceof VoidPointerType and type = "pointer-to-void"
  ) and
  c.getType() instanceof PointerType
select c, "Object with " + type + " type converted to an object with pointer type. "

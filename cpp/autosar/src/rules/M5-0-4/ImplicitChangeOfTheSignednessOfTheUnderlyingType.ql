/**
 * @id cpp/autosar/implicit-change-of-the-signedness-of-the-underlying-type
 * @name M5-0-4: An implicit integral conversion shall not change the signedness of the underlying type
 * @description An implicit integral conversion shall not change the signedness of the underlying
 *              type, because this may lead to implementation-defined behavior that can be
 *              inconsistent with developer expectations.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-0-4
 *       correctness
 *       external/autosar/strict
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Conversion

from MisraConversion::ImplicitIntegralConversion c, IntegralType it1, IntegralType it2
where
  not isExcluded(c,
    IntegerConversionPackage::implicitChangeOfTheSignednessOfTheUnderlyingTypeQuery()) and
  c.isImplicit() and
  not c.isAffectedByMacro() and
  it1 = MisraConversion::getUnderlyingType(c.getExpr()).getUnderlyingType() and
  it2 = MisraConversion::getUnderlyingType(c).getUnderlyingType() and
  (
    it1.isSigned() and it2.isUnsigned()
    or
    it1.isUnsigned() and it2.isSigned()
  ) and
  not c.isFromUninstantiatedTemplate(_) and
  c.getType().getUnderlyingType() instanceof IntegralType
select c.getExpr(),
  "Implicit integral $@ changed the signedness of the underlying type from " + it1.getName() +
    " to " + it2.getName() + ".", c, "conversion"

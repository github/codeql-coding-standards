/**
 * @id cpp/autosar/explicit-signedness-conversion-of-c-value
 * @name M5-0-9: An explicit integral conversion shall not change the signedness of the underlying type of a cvalue
 * @description An explicit integral conversion shall not change the signedness of the underlying
 *              type of a cvalue expression, because the resulting value may be inconsistent with
 *              the expectations of a developer.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-0-9
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Conversion
import codingstandards.cpp.Expr

predicate determineTypes(
  MisraConversion::ExplicitCValueConversion c, IntegralType before, IntegralType after
) {
  before = MisraConversion::getUnderlyingType(c.getCValue()).getUnderlyingType() and
  after = c.getUnderlyingType()
}

from
  MisraConversion::ExplicitCValueConversion c, IntegralType before, IntegralType after,
  string fromSignedness, string toSignedness
where
  not isExcluded(c, IntegerConversionPackage::explicitSignednessConversionOfCValueQuery()) and
  determineTypes(c, before, after) and
  (
    before.isSigned() and
    after.isUnsigned() and
    fromSignedness = "signed" and
    toSignedness = "unsigned"
    or
    before.isUnsigned() and
    after.isSigned() and
    fromSignedness = "unsigned" and
    toSignedness = "signed"
  )
select c,
  "Explicit integral conversion converts the signedness of the $@ from " + fromSignedness + " to " +
    toSignedness + ".", c.getCValue(), "cvalue"

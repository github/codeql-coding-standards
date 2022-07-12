/**
 * @id cpp/autosar/nested-zero-value-initialization
 * @name M8-5-2: The zero initialization of arrays or structures shall only be applied at the top level
 * @description It can be confusing to the developer if the structure of braces in an initializer
 *              does not match the structure of the object being initialized.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/m8-5-2
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.enhancements.AggregateLiteralEnhancements

from AggregateLiteral al
where
  not isExcluded(al, InitializationPackage::nestedZeroValueInitializationQuery()) and
  // A nested aggregate literal
  al.getParent() instanceof AggregateLiteral and
  // Not value initialized
  not isExprValueInitialized(_, al) and
  // Use blank or leading-zero initialization form
  (
    isLeadingZeroInitialized(al) or
    isBlankInitialized(al)
  ) and
  not isLeadingZeroInitialized(getRootAggregate(al))
select al, "Nested aggregate literal intialized with a leading zero."

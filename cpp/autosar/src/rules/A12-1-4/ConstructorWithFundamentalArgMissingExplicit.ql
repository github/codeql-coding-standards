/**
 * @id cpp/autosar/constructor-with-fundamental-arg-missing-explicit
 * @name A12-1-4: All constructors that are callable with a single argument of fundamental type shall be declared explicit
 * @description Constructors which are not marked explicit may be used in implicit conversions,
 *              which may be unexpected for fundamental types.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a12-1-4
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Type

from Constructor c, FundamentalType f
where
  not isExcluded(c, InitializationPackage::constructorWithFundamentalArgMissingExplicitQuery()) and
  // Can be called with a single argument if...
  (
    // ...there is only one parameter
    c.getNumberOfParameters() = 1
    or
    // ...or the parameter in position 1 has a default argument, and therefore it, and the rest of
    // the arguments, are optional
    c.getParameter(1).hasInitializer()
  ) and
  // The first parameter is of a fundamental type
  f = c.getParameter(0).getType().getUnspecifiedType() and
  // And the constructor does not have an explicit specifier
  not c.hasSpecifier("explicit")
select c,
  "Constructor for " + c.getDeclaringType().getName() + " accepts the fundamental type " +
    f.getName() + " but is not marked explicit to avoid unexpected implicit conversions."

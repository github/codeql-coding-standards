/**
 * @id cpp/autosar/enumeration-underlying-base-type-not-explicitly-defined
 * @name A7-2-2: Enumeration underlying base type shall be explicitly defined
 * @description Although scoped enum will implicitly define an underlying type of int, the
 *              underlying base type of enumeration should always be explicitly defined with a type
 *              that will be large enough to store all enumerators.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-2-2
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Enum e
where
  not isExcluded(e, DeclarationsPackage::enumerationUnderlyingBaseTypeNotExplicitlyDefinedQuery()) and
  not e.hasExplicitUnderlyingType()
select e, "Base type of enumeration is not explicitly specified."

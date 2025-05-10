/**
 * @id cpp/autosar/type-long-double-used
 * @name A0-4-2: Type long double shall not be used
 * @description The type long double has an implementation-defined width and therefore shall not be
 *              used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-4-2
 *       correctness
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.CodingStandards
import codingstandards.cpp.exclusions.cpp.RuleMetadata

predicate isUsingLongDouble(ClassTemplateInstantiation c) {
  c.getATemplateArgument() instanceof LongDoubleType or
  isUsingLongDouble(c.getATemplateArgument())
}

from Variable v
where
  not isExcluded(v, BannedTypesPackage::typeLongDoubleUsedQuery()) and
  (
    v.getUnderlyingType() instanceof LongDoubleType and
    not v.isFromTemplateInstantiation(_)
    or
    exists(ClassTemplateInstantiation c |
      c = v.getType() and
      isUsingLongDouble(c)
    )
  )
select v, "Use of long double type."

/**
 * @id cpp/autosar/use-of-enum-for-related-constants
 * @name A7-2-5: (Audit) Enumerations should be used to represent sets of related named constants
 * @description An enumeration should only be used to represent a set of related, named constants.
 * @kind problem
 * @precision low
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-2-5
 *       external/autosar/audit
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from Enum e
where not isExcluded(e, TypeRangesPackage::useOfEnumForRelatedConstantsQuery())
select e, "[AUDIT] Confirm enum represents a set of related named constants."

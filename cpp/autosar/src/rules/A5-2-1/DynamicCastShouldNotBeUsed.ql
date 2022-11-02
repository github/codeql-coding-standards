/**
 * @id cpp/autosar/dynamic-cast-should-not-be-used
 * @name A5-2-1: dynamic_cast should not be used
 * @description The statement dynamic_cast should not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a5-2-1
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from DynamicCast dc
where not isExcluded(dc, BannedSyntaxPackage::dynamicCastShouldNotBeUsedQuery())
select dc, "Use of dynamic_cast"

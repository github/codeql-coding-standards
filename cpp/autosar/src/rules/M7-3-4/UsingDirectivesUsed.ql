/**
 * @id cpp/autosar/using-directives-used
 * @name M7-3-4: Using-directives shall not be used
 * @description Using namespace directives shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m7-3-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from UsingDirectiveEntry u
where not isExcluded(u, BannedSyntaxPackage::usingDirectivesUsedQuery())
select u, "Use of 'using' directive."

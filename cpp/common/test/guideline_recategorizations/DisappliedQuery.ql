/**
 * @id cpp/guideline-recategorizations/disapplied-query
 * @name Query based on A0-1-6 to test disapplied category
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-1-6
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.CodingStandards
import codingstandards.cpp.TypeUses
import codingstandards.cpp.exclusions.cpp.RuleMetadata

from UserType ut, string reason
where
  isExcluded(ut, DeadCodePackage::unusedTypeDeclarationsQuery(), reason) and
  exists(ut.getFile()) and
  not ut instanceof TemplateParameter and
  not ut instanceof ProxyClass and
  not exists(getATypeUse(ut)) and
  not ut.isFromUninstantiatedTemplate(_)
select ut,
  "Unused type declaration " + ut.getName() + " is not reported with reason '" + reason + "'."

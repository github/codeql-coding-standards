/**
 * @id c/misra/unused-object-definition
 * @name RULE-2-8: A project should not contain unused object definitions
 * @description Object definitions which are unused should be removed.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-2-8
 *       maintainability
 *       performance
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.deadcode.UnusedObjects

from ReportDeadObject report
where
  not isExcluded(report.getPrimaryElement(), DeadCode2Package::unusedObjectDefinitionQuery()) and
  not report.hasAttrUnused()
select report.getPrimaryElement(), report.getMessage(), report.getOptionalPlaceholderLocatable(),
  report.getOptionalPlaceholderMessage()

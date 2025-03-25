/**
 * @id c/misra/unused-object-definition-strict
 * @name RULE-2-8: A project should not contain '__attribute__((unused))' object definitions
 * @description A strict query which reports all unused object definitions with
 *              '__attribute__((unused))'.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-2-8
 *       maintainability
 *       performance
 *       external/misra/c/2012/amendment4
 *       external/misra/c/strict
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.deadcode.UnusedObjects

from ReportDeadObject report
where
  not isExcluded(report.getPrimaryElement(), DeadCode2Package::unusedObjectDefinitionStrictQuery()) and
  report.hasAttrUnused()
select report.getPrimaryElement(), report.getMessage(), report.getOptionalPlaceholderLocatable(),
  report.getOptionalPlaceholderMessage()

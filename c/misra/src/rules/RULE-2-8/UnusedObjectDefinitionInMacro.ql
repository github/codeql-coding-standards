/**
 * @id c/misra/unused-object-definition-in-macro
 * @name RULE-2-8: Project macros should not include unused object definitions
 * @description Macros should not have unused object definitions.
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

from ReportDeadObjectInMacro report
where
  not isExcluded(report.getPrimaryElement(), DeadCode2Package::unusedObjectDefinitionInMacroQuery()) and
  not report.hasAttrUnused()
select report.getPrimaryElement(), report.getMessage(), report.getOptionalPlaceholderLocation(),
  report.getOptionalPlaceholderMessage()

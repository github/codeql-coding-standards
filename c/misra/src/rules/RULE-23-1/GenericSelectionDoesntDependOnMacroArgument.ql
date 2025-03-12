/**
 * @id c/misra/generic-selection-doesnt-depend-on-macro-argument
 * @name RULE-23-1: A generic selection should depend on the type of a macro argument
 * @description A generic selection should depend on the type of a macro argument.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-23-1
 *       correctness
 *       maintainability
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Generic

from ParsedGenericMacro macro, string ctrlExpr
where
  not isExcluded(macro, GenericsPackage::genericSelectionDoesntDependOnMacroArgumentQuery()) and
  ctrlExpr = macro.getControllingExprString().trim() and
  not macro.expansionsInsideControllingExpr(_) > 0
select macro,
  "Generic macro " + macro.getName() + " uses controlling expr " + ctrlExpr +
    ", which doesn't match any macro parameter."

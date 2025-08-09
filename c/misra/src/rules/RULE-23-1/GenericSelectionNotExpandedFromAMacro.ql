/**
 * @id c/misra/generic-selection-not-expanded-from-a-macro
 * @name RULE-23-1: A generic selection should only be expanded from a macro
 * @description A generic selection should only be expanded from a macro.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-23-1
 *       maintainability
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from C11GenericExpr generic, Expr ctrlExpr
where
  not isExcluded(generic, GenericsPackage::genericSelectionNotExpandedFromAMacroQuery()) and
  ctrlExpr = generic.getControllingExpr() and
  not exists(MacroInvocation mi | mi.getAGeneratedElement() = generic.getExpr())
select generic, "$@ in generic expression does not expand a macro parameter.", ctrlExpr,
  "Controlling expression"

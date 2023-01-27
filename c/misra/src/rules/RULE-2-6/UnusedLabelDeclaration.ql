/**
 * @id c/misra/unused-label-declaration
 * @name RULE-2-6: A function should not contain unused label declarations
 * @description Unused label declarations are either redundant or indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-2-6
 *       readability
 *       maintainability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from LabelStmt label
where
  not isExcluded(label, DeadCodePackage::unusedLabelDeclarationQuery()) and
  // No GotoStmt jumps to this label
  not exists(GotoStmt gs | gs.hasName() and gs.getTarget() = label) and
  // The address of the label is never taken
  not exists(LabelLiteral literal | literal.getLabel() = label)
select label, "Label " + label.getName() + " is unused."

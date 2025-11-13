/**
 * @id c/misra/goto-label-block-condition
 * @name RULE-15-3: The goto statement and any of its label shall be declared or enclosed in the same block
 * @description Any label referenced by a goto statement shall be declared in the same block, or in
 *              any block enclosing the goto statement.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-15-3
 *       maintainability
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 *       coding-standards/baseline/safety
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.gotoreferencealabelinsurroundingblock.GotoReferenceALabelInSurroundingBlock

class GotoLabelBlockConditionQuery extends GotoReferenceALabelInSurroundingBlockSharedQuery {
  GotoLabelBlockConditionQuery() { this = Statements2Package::gotoLabelBlockConditionQuery() }
}

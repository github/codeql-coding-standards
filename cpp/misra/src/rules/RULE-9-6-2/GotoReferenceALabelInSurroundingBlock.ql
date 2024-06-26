/**
 * @id cpp/misra/goto-reference-a-label-in-surrounding-block
 * @name RULE-9-6-2: A goto statement shall reference a label in a surrounding block
 * @description A goto statement shall reference a label in a surrounding block.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-6-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.gotoreferencealabelinsurroundingblock_shared.GotoReferenceALabelInSurroundingBlock_shared

class GotoReferenceALabelInSurroundingBlockQuery extends GotoReferenceALabelInSurroundingBlock_sharedSharedQuery
{
  GotoReferenceALabelInSurroundingBlockQuery() {
    this = ImportMisra23Package::gotoReferenceALabelInSurroundingBlockQuery()
  }
}

/**
 * @id cpp/misra/object-used-while-in-potentially-moved-from-state
 * @name RULE-28-6-3: An object shall not be used while in a potentially moved-from state
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-28-6-3
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.movedfromobjectsunspecifiedstate.MovedFromObjectsUnspecifiedState

class ObjectUsedWhileInPotentiallyMovedFromStateQuery extends MovedFromObjectsUnspecifiedStateSharedQuery {
  ObjectUsedWhileInPotentiallyMovedFromStateQuery() {
    this = ImportMisra23Package::objectUsedWhileInPotentiallyMovedFromStateQuery()
  }
}

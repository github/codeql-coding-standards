/**
 * @id cpp/cert/do-not-rely-on-the-value-of-a-moved-from-object
 * @name EXP63-CPP: Do not rely on the value of a moved-from object
 * @description Do not rely on the value of a moved-from object.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp63-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.movedfromobjectsunspecifiedstate.MovedFromObjectsUnspecifiedState

class DoNotRelyOnTheValueOfAMovedFromObjectQuery extends MovedFromObjectsUnspecifiedStateSharedQuery {
  DoNotRelyOnTheValueOfAMovedFromObjectQuery() {
    this = MoveForwardPackage::doNotRelyOnTheValueOfAMovedFromObjectQuery()
  }
}

/**
 * @id cpp/autosar/moved-from-object-read-accessed
 * @name A12-8-3: Moved-from object shall not be read-accessed
 * @description Moved-from object shall not be read-accessed.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a12-8-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.movedfromobjectsunspecifiedstate.MovedFromObjectsUnspecifiedState

class MovedFromObjectReadAccessedQuery extends MovedFromObjectsUnspecifiedStateSharedQuery {
  MovedFromObjectReadAccessedQuery() {
    this = MoveForwardPackage::movedFromObjectReadAccessedQuery()
  }
}

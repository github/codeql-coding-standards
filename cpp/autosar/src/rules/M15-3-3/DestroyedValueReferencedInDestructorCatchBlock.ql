/**
 * @id cpp/autosar/destroyed-value-referenced-in-destructor-catch-block
 * @name M15-3-3: Handlers of a function-try-block implementation of a class constructor or destructor shall not reference non-static members from this class or its bases
 * @description Referring to any non-static member or base class of an object in the handler for a
 *              function-try-block of a constructor or destructor for that object results in
 *              undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m15-3-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.destroyedvaluereferencedindestructorcatchblock.DestroyedValueReferencedInDestructorCatchBlock

class DestroyedValueReferencedInDestructorCatchBlockQuery extends DestroyedValueReferencedInDestructorCatchBlockSharedQuery {
  DestroyedValueReferencedInDestructorCatchBlockQuery() {
    this = Exceptions2Package::destroyedValueReferencedInDestructorCatchBlockQuery()
  }
}

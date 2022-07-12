/**
 * @id cpp/cert/destroyed-value-referenced-in-constructor-destructor-catch-block
 * @name ERR53-CPP: Do not reference base classes or class data members in a constructor or destructor function-try-block handler
 * @description Referring to any non-static member or base class of an object in the handler for a
 *              function-try-block of a constructor or destructor for that object results in
 *              undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/err53-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.destroyedvaluereferencedindestructorcatchblock.DestroyedValueReferencedInDestructorCatchBlock

class DestroyedValueReferencedInConstructorDestructorCatchBlockQuery extends DestroyedValueReferencedInDestructorCatchBlockSharedQuery {
  DestroyedValueReferencedInConstructorDestructorCatchBlockQuery() {
    this = Exceptions2Package::destroyedValueReferencedInDestructorCatchBlockQuery()
  }
}

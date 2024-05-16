/**
 * @id cpp/misra/handlers-refer-to-non-static-members-from-their-class
 * @name RULE-18-3-3: Handlers for a function-try-block of a constructor or destructor shall not refer to non-static
 * @description Handlers for a function-try-block of a constructor or destructor shall not refer to
 *              non-static members from their class or its bases.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-3-3
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.destroyedvaluereferencedindestructorcatchblock.DestroyedValueReferencedInDestructorCatchBlock

class HandlersReferToNonStaticMembersFromTheirClassQuery extends DestroyedValueReferencedInDestructorCatchBlockSharedQuery {
  HandlersReferToNonStaticMembersFromTheirClassQuery() {
    this = ImportMisra23Package::handlersReferToNonStaticMembersFromTheirClassQuery()
  }
}

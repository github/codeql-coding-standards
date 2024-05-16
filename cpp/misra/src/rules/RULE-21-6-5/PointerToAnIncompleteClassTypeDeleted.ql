/**
 * @id cpp/misra/pointer-to-an-incomplete-class-type-deleted
 * @name RULE-21-6-5: A pointer to an incomplete class type shall not be deleted
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-6-5
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.deleteofpointertoincompleteclass.DeleteOfPointerToIncompleteClass

class PointerToAnIncompleteClassTypeDeletedQuery extends DeleteOfPointerToIncompleteClassSharedQuery {
  PointerToAnIncompleteClassTypeDeletedQuery() {
    this = ImportMisra23Package::pointerToAnIncompleteClassTypeDeletedQuery()
  }
}

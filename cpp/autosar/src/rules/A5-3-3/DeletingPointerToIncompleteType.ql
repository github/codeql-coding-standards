/**
 * @id cpp/autosar/deleting-pointer-to-incomplete-type
 * @name A5-3-3: Pointers to incomplete class types shall not be deleted
 * @description Pointers to incomplete class types shall not be deleted because it results in
 *              undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a5-3-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.deleteofpointertoincompleteclass.DeleteOfPointerToIncompleteClass

class DeletingPointerToIncompleteTypeQuery extends DeleteOfPointerToIncompleteClassSharedQuery {
  DeletingPointerToIncompleteTypeQuery() {
    this = PointersPackage::deletingPointerToIncompleteTypeQuery()
  }
}

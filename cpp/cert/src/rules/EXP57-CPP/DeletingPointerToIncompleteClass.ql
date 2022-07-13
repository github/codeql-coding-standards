/**
 * @id cpp/cert/deleting-pointer-to-incomplete-class
 * @name EXP57-CPP: Do not delete pointers to incomplete classes
 * @description Do not delete pointers to incomplete classes to prevent undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp57-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.deleteofpointertoincompleteclass.DeleteOfPointerToIncompleteClass

class DeletingPointerToIncompleteClassQuery extends DeleteOfPointerToIncompleteClassSharedQuery {
  DeletingPointerToIncompleteClassQuery() {
    this = PointersPackage::deletingPointerToIncompleteClassQuery()
  }
}

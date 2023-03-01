/**
 * @id cpp/autosar/null-pointers-dereferenced
 * @name A5-3-2: Null pointers shall not be dereferenced
 * @description Dereferencing a NULL pointer leads to undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/autosar/id/a5-3-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.dereferenceofnullpointer.DereferenceOfNullPointer

class NullPointersDereferencedQuery extends DereferenceOfNullPointerSharedQuery {
  NullPointersDereferencedQuery() {
    this = NullPackage::nullPointersDereferencedQuery()
  }
}

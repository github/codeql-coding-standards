/**
 * @id cpp/autosar/owned-pointer-value-stored-in-unrelated-smart-pointer-asar
 * @name A20-8-1: An already-owned pointer value shall not be stored in an unrelated smart pointer
 * @description Pointers stored in unrelated smart pointers can be erroneously destroyed upon a
 *              single underlying pointer going out of scope.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a20-8-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.ownedpointervaluestoredinunrelatedsmartpointer.OwnedPointerValueStoredInUnrelatedSmartPointer

class OwnedPointerValueStoredInUnrelatedSmartPointerAsarQuery extends OwnedPointerValueStoredInUnrelatedSmartPointerSharedQuery {
  OwnedPointerValueStoredInUnrelatedSmartPointerAsarQuery() {
    this = SmartPointers1Package::ownedPointerValueStoredInUnrelatedSmartPointerAsarQuery()
  }
}

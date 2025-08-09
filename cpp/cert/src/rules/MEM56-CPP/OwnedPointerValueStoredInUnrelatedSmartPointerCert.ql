/**
 * @id cpp/cert/owned-pointer-value-stored-in-unrelated-smart-pointer-cert
 * @name MEM56-CPP: Do not store an already-owned pointer value in an unrelated smart pointer
 * @description Pointers stored in unrelated smart pointers can be erroneously destroyed upon a
 *              single underlying pointer going out of scope.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/mem56-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.ownedpointervaluestoredinunrelatedsmartpointer.OwnedPointerValueStoredInUnrelatedSmartPointer

class OwnedPointerValueStoredInUnrelatedSmartPointerCertQuery extends OwnedPointerValueStoredInUnrelatedSmartPointerSharedQuery
{
  OwnedPointerValueStoredInUnrelatedSmartPointerCertQuery() {
    this = SmartPointers2Package::ownedPointerValueStoredInUnrelatedSmartPointerCertQuery()
  }
}

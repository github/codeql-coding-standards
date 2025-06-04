/**
 * @id c/cert/do-not-dereference-null-pointers
 * @name EXP34-C: Do not dereference null pointers
 * @description Dereferencing a null pointer leads to undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/exp34-c
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.dereferenceofnullpointer.DereferenceOfNullPointer

class DoNotDereferenceNullPointersQuery extends DereferenceOfNullPointerSharedQuery {
  DoNotDereferenceNullPointersQuery() {
    this = InvalidMemory1Package::doNotDereferenceNullPointersQuery()
  }
}

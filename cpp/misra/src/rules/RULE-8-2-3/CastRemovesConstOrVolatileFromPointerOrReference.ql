/**
 * @id cpp/misra/cast-removes-const-or-volatile-from-pointer-or-reference
 * @name RULE-8-2-3: A cast shall not remove any const or volatile qualification from the type accessed via a pointer or
 * @description A cast shall not remove any const or volatile qualification from the type accessed
 *              via a pointer or by reference.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-3
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.removeconstorvolatilequalification.RemoveConstOrVolatileQualification

class CastRemovesConstOrVolatileFromPointerOrReferenceQuery extends RemoveConstOrVolatileQualificationSharedQuery {
  CastRemovesConstOrVolatileFromPointerOrReferenceQuery() {
    this = ImportMisra23Package::castRemovesConstOrVolatileFromPointerOrReferenceQuery()
  }
}

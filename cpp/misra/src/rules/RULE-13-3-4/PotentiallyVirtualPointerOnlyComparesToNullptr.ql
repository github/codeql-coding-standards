/**
 * @id cpp/misra/potentially-virtual-pointer-only-compares-to-nullptr
 * @name RULE-13-3-4: A comparison of a potentially virtual pointer to member function shall only be with nullptr
 * @description A comparison of a potentially virtual pointer to member function shall only be with
 *              nullptr.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-3-4
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.potentiallyvirtualpointeronlycomparestonullptr_shared.PotentiallyVirtualPointerOnlyComparesToNullptr_shared

class PotentiallyVirtualPointerOnlyComparesToNullptrQuery extends PotentiallyVirtualPointerOnlyComparesToNullptr_sharedSharedQuery
{
  PotentiallyVirtualPointerOnlyComparesToNullptrQuery() {
    this = ImportMisra23Package::potentiallyVirtualPointerOnlyComparesToNullptrQuery()
  }
}

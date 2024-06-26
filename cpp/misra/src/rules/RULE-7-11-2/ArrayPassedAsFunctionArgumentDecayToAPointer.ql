/**
 * @id cpp/misra/array-passed-as-function-argument-decay-to-a-pointer
 * @name RULE-7-11-2: An array passed as a function argument shall not decay to a pointer
 * @description An array passed as a function argument shall not decay to a pointer.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-11-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.arraypassedasfunctionargumentdecaytoapointer_shared.ArrayPassedAsFunctionArgumentDecayToAPointer_shared

class ArrayPassedAsFunctionArgumentDecayToAPointerQuery extends ArrayPassedAsFunctionArgumentDecayToAPointer_sharedSharedQuery {
  ArrayPassedAsFunctionArgumentDecayToAPointerQuery() {
    this = ImportMisra23Package::arrayPassedAsFunctionArgumentDecayToAPointerQuery()
  }
}

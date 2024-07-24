/**
 * @id cpp/autosar/identifier-passed-as-function-argument-decay-to-a-pointer
 * @name M5-2-12: An identifier with array type passed as a function argument shall not decay to a pointer
 * @description An identifier with array type passed as a function argument shall not decay to a
 *              pointer to prevent loss of its bounds.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-2-12
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.arraypassedasfunctionargumentdecaytoapointer.ArrayPassedAsFunctionArgumentDecayToAPointer

class IdentifierPassedAsFunctionArgumentDecayToAPointerQuery extends ArrayPassedAsFunctionArgumentDecayToAPointerSharedQuery
{
  IdentifierPassedAsFunctionArgumentDecayToAPointerQuery() {
    this = PointersPackage::identifierPassedAsFunctionArgumentDecayToAPointerQuery()
  }
}

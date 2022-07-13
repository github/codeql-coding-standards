/**
 * @id cpp/autosar/pointer-and-derived-pointer-access-different-array
 * @name M5-0-16: A pointer operand and any pointer resulting from pointer arithmetic using that operand shall both
 * @description A pointer operand and any pointer resulting from pointer arithmetic using that
 *              operand shall both address elements of the same array.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/autosar/id/m5-0-16
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.donotusepointerarithmetictoaddressdifferentarrays.DoNotUsePointerArithmeticToAddressDifferentArrays

class PointerAndDerivedPointerAccessDifferentArrayQuery extends DoNotUsePointerArithmeticToAddressDifferentArraysSharedQuery {
  PointerAndDerivedPointerAccessDifferentArrayQuery() {
    this = PointersPackage::pointerAndDerivedPointerAccessDifferentArrayQuery()
  }
}

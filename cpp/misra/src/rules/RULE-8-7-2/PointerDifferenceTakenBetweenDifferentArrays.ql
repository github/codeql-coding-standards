/**
 * @id cpp/misra/pointer-difference-taken-between-different-arrays
 * @name RULE-8-7-2: Subtraction between pointers shall only be applied to ones that address elements of the same array
 * @description Pointer difference should be taken from pointers that belong to a same array.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-8-7-2
 *       scope/system
 *       correctness
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.donotsubtractpointersaddressingdifferentarrays.DoNotSubtractPointersAddressingDifferentArrays

class PointerDifferenceTakenBetweenDifferentArraysQuery extends DoNotSubtractPointersAddressingDifferentArraysSharedQuery
{
  PointerDifferenceTakenBetweenDifferentArraysQuery() {
    this = Memory2Package::pointerDifferenceTakenBetweenDifferentArraysQuery()
  }
}

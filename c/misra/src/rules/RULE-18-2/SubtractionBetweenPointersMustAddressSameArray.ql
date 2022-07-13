/**
 * @id c/misra/subtraction-between-pointers-must-address-same-array
 * @name RULE-18-2: Subtraction between pointers shall only be applied to pointers that address elements of the same array
 * @description Subtraction between pointers which do not both point to elements of the same array
 *              results in undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-18-2
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.donotsubtractpointersaddressingdifferentarrays.DoNotSubtractPointersAddressingDifferentArrays

class SubtractionBetweenPointersMustAddressSameArrayQuery extends DoNotSubtractPointersAddressingDifferentArraysSharedQuery {
  SubtractionBetweenPointersMustAddressSameArrayQuery() {
    this = Pointers1Package::subtractionBetweenPointersMustAddressSameArrayQuery()
  }
}

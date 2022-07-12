/**
 * @id c/misra/pointer-and-derived-pointer-must-address-same-array
 * @name RULE-18-1: A pointer resulting from arithmetic on a pointer operand shall address an element of the same array
 * @description A pointer resulting from arithmetic on a pointer operand shall address an element of
 *              the same array as that pointer operand.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-18-1
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.donotusepointerarithmetictoaddressdifferentarrays.DoNotUsePointerArithmeticToAddressDifferentArrays

class PointerAndDerivedPointerMustAddressSameArrayQuery extends DoNotUsePointerArithmeticToAddressDifferentArraysSharedQuery {
  PointerAndDerivedPointerMustAddressSameArrayQuery() {
    this = Pointers1Package::pointerAndDerivedPointerMustAddressSameArrayQuery()
  }
}

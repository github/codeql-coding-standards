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
 *       external/misra/c/2012/third-edition-first-revision
 *       external/cwe/cwe-119
 *       external/cwe/cwe-120
 *       external/cwe/cwe-121
 *       external/cwe/cwe-122
 *       external/cwe/cwe-123
 *       external/cwe/cwe-124
 *       external/cwe/cwe-125
 *       external/cwe/cwe-126
 *       external/cwe/cwe-127
 *       external/cwe/cwe-129
 *       external/cwe/cwe-131
 *       external/cwe/cwe-466
 *       external/cwe/cwe-680
 *       external/cwe/cwe-786
 *       external/cwe/cwe-787
 *       external/cwe/cwe-788
 *       external/cwe/cwe-823
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.donotusepointerarithmetictoaddressdifferentarrays.DoNotUsePointerArithmeticToAddressDifferentArrays

class PointerAndDerivedPointerMustAddressSameArrayQuery extends DoNotUsePointerArithmeticToAddressDifferentArraysSharedQuery
{
  PointerAndDerivedPointerMustAddressSameArrayQuery() {
    this = Pointers1Package::pointerAndDerivedPointerMustAddressSameArrayQuery()
  }
}

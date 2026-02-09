/**
 * @id c/misra/cast-between-pointer-to-void-and-arithmetic-type
 * @name RULE-11-6: A cast shall not be performed between pointer to void and an arithmetic type
 * @description Converting from an integer into a pointer to void may result in an incorrectly
 *              aligned pointer and undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-6
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.types.Pointers

from CStyleCast cast, Type typeFrom, Type typeTo
where
  not isExcluded(cast, Pointers1Package::castBetweenPointerToVoidAndArithmeticTypeQuery()) and
  typeFrom = cast.getExpr().getUnderlyingType() and
  typeTo = cast.getUnderlyingType() and
  [typeFrom, typeTo] instanceof ArithmeticType and
  [typeFrom, typeTo] instanceof VoidPointerType and
  not cast.getExpr() instanceof Zero
select cast, "Cast performed between a pointer to void type and an arithmetic type."

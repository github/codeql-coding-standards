/**
 * @id c/misra/conversion-between-function-pointer-and-other-type
 * @name RULE-11-1: Conversions shall not be performed between a pointer to a function and any other type
 * @description Converting between a function pointer into an incompatible type results in undefined
 *              behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-1
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Pointers

from CStyleCast cast, Type type, Type newType
where
  not isExcluded(cast, Pointers1Package::conversionBetweenFunctionPointerAndOtherTypeQuery()) and
  type = cast.getExpr().getUnderlyingType() and
  newType = cast.getUnderlyingType() and
  [type, newType] instanceof FunctionPointerType and
  type != newType and
  // exception 1 (null pointer constant)
  not isNullPointerConstant(cast.getExpr()) and
  // exception 2 (conversion to void)
  not newType instanceof VoidType
select cast, "Cast performed between a function pointer and another type."

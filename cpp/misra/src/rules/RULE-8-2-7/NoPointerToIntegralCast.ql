/**
 * @id cpp/misra/no-pointer-to-integral-cast
 * @name RULE-8-2-7: A cast should not convert a pointer type to an integral type
 * @description Casting between pointer types and integral types makes code behavior harder to
 *              understand and may cause pointer tracking tools to become unreliable.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-7
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from Cast cast, Type sourceType, IntegralType targetType
where
  not isExcluded(cast, Conversions2Package::noPointerToIntegralCastQuery()) and
  sourceType = cast.getExpr().getType().getUnspecifiedType() and
  targetType = cast.getType().getUnspecifiedType() and
  (sourceType instanceof PointerType or sourceType instanceof FunctionPointerType)
select cast, "Cast converts pointer type to integral type '" + targetType + "'."

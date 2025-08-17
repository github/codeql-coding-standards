/**
 * @id cpp/misra/int-to-pointer-cast-prohibited
 * @name RULE-8-2-6: An object with integral, enumerated, or pointer to void type shall not be cast to a pointer type
 * @description Casting from an integral type, enumerated type, or pointer to void type to a pointer
 *              type leads to unspecified behavior and is error prone.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-6
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from Cast cast, Type sourceType, Type targetType
where
  not isExcluded(cast, Conversions2Package::intToPointerCastProhibitedQuery()) and
  sourceType = cast.getExpr().getType().stripTopLevelSpecifiers() and
  targetType = cast.getType().stripTopLevelSpecifiers() and
  targetType instanceof PointerType and
  not targetType instanceof FunctionPointerType and
  not (
    // Exception: casts between void pointers are allowed
    targetType.(PointerType).getBaseType().stripTopLevelSpecifiers() instanceof VoidType and
    sourceType instanceof PointerType and
    sourceType.(PointerType).getBaseType().stripTopLevelSpecifiers() instanceof VoidType
  ) and
  (
    // Integral types
    sourceType instanceof IntegralType
    or
    // Enumerated types
    sourceType instanceof Enum
    or
    // Pointer to void type
    sourceType instanceof PointerType and
    sourceType.(PointerType).getBaseType().stripTopLevelSpecifiers() instanceof VoidType
  )
select cast,
  "Cast from '" + sourceType.toString() + "' to '" + targetType.toString() + "' is prohibited."

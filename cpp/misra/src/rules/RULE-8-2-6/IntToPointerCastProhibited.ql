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
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from Cast cast, Type sourceType, PointerType targetType, string typeKind
where
  not isExcluded(cast, Conversions2Package::intToPointerCastProhibitedQuery()) and
  sourceType = cast.getExpr().getType().getUnspecifiedType() and
  targetType = cast.getType().getUnspecifiedType() and
  (
    // Integral types
    sourceType instanceof IntegralType and
    typeKind = "integral"
    or
    // Enumerated types
    sourceType instanceof Enum and
    typeKind = "enumerated"
    or
    // Pointer to void type
    sourceType.(PointerType).getBaseType() instanceof VoidType and
    typeKind = "pointer to void" and
    // Exception: casts between void pointers are allowed
    not targetType.getBaseType() instanceof VoidType
  )
select cast,
  "Cast from " + typeKind + " type '" + cast.getExpr().getType() + "' to pointer type '" +
    cast.getType() + "'."

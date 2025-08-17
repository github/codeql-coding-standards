/**
 * @id cpp/misra/pointer-to-integral-cast
 * @name RULE-8-2-8: An object pointer type shall not be cast to an integral type other than std::uintptr_t or
 * @description Casting object pointers to integral types other than std::uintptr_t or std::intptr_t
 *              can lead to implementation-defined behavior and potential loss of pointer
 *              information.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-8
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from ReinterpretCast cast, Type targetType, Type sourceType
where
  not isExcluded(cast, Conversions2Package::pointerToIntegralCastQuery()) and
  sourceType = cast.getExpr().getType().getUnspecifiedType() and
  sourceType instanceof PointerType and
  targetType = cast.getType() and
  targetType.getUnspecifiedType() instanceof IntegralType and
  not (
    targetType.(UserType).hasGlobalOrStdName("uintptr_t") or
    targetType.(UserType).hasGlobalOrStdName("intptr_t")
  )
select cast,
  "Cast of object pointer type to integral type '" + targetType.toString() +
    "' instead of 'std::uintptr_t' or 'std::intptr_t'."

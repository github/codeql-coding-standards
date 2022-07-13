/**
 * @id c/misra/cast-between-object-pointer-and-different-object-type
 * @name RULE-11-3: A cast shall not be performed between a pointer to object type and a pointer to a different object
 * @description Casting between an object pointer and a pointer to a different object type can
 *              result in a pointer that is incorrectly aligned or that results in undefined
 *              behaviour if accessed.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-3
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Pointers

from CStyleCast cast, Type baseTypeFrom, Type baseTypeTo
where
  not isExcluded(cast, Pointers1Package::castBetweenObjectPointerAndDifferentObjectTypeQuery()) and
  baseTypeFrom = cast.getExpr().getType().(PointerToObjectType).getBaseType() and
  baseTypeTo = cast.getType().(PointerToObjectType).getBaseType() and
  // exception: cast to a char, signed char, or unsigned char is permitted
  not baseTypeTo.stripType() instanceof CharType and
  (
    (
      baseTypeFrom.isVolatile() and not baseTypeTo.isVolatile()
      or
      baseTypeFrom.isConst() and not baseTypeTo.isConst()
    )
    or
    baseTypeFrom.stripType() != baseTypeTo.stripType()
  )
select cast,
  "Cast performed between a pointer to object type (" + baseTypeFrom.getName() +
    ") and a pointer to a different object type (" + baseTypeTo.getName() + ")."

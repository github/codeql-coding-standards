/**
 * @id c/misra/cast-removes-const-or-volatile-qualification
 * @name RULE-11-8: A cast shall not remove any const or volatile qualification from the type pointed to by a pointer
 * @description Casting away const or volatile qualifications violates the principle of type
 *              qualification and can result in unpredictable behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-8
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Cast cast, Type baseTypeFrom, Type baseTypeTo, string qualificationName
where
  not isExcluded(cast, Pointers1Package::castRemovesConstOrVolatileQualificationQuery()) and
  baseTypeFrom = cast.getExpr().getType().(PointerType).getBaseType() and
  baseTypeTo = cast.getType().(PointerType).getBaseType() and
  (
    baseTypeFrom.isVolatile() and not baseTypeTo.isVolatile() and qualificationName = "volatile"
    or
    baseTypeFrom.isConst() and not baseTypeTo.isConst() and qualificationName = "const"
  )
select cast, "Cast of pointer removes " + qualificationName + " qualification from its base type."

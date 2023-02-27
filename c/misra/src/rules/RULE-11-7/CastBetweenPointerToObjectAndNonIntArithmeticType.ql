/**
 * @id c/misra/cast-between-pointer-to-object-and-non-int-arithmetic-type
 * @name RULE-11-7: A cast shall not be performed between pointer to object and a non-integer arithmetic type
 * @description Converting between a pointer to an object and a pointer to a non-integer arithmetic
 *              type can result in undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-7
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Pointers

class MisraNonIntegerArithmeticType extends Type {
  MisraNonIntegerArithmeticType() {
    this instanceof BoolType or
    this instanceof CharType or
    this instanceof Enum or
    this instanceof FloatingPointType
  }
}

from CStyleCast cast, Type typeFrom, Type typeTo
where
  not isExcluded(cast, Pointers1Package::castBetweenPointerToObjectAndNonIntArithmeticTypeQuery()) and
  typeFrom = cast.getExpr().getUnderlyingType() and
  typeTo = cast.getUnderlyingType() and
  [typeFrom, typeTo] instanceof MisraNonIntegerArithmeticType and
  [typeFrom, typeTo] instanceof PointerToObjectType
select cast,
  "Cast performed between a pointer to object type and a non-integer arithmetic type."
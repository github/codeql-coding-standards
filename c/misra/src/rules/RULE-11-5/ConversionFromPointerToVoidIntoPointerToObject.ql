/**
 * @id c/misra/conversion-from-pointer-to-void-into-pointer-to-object
 * @name RULE-11-5: A conversion should not be performed from pointer to void into pointer to object
 * @description Converting from a pointer to void into a pointer to an object may result in an
 *              incorrectly aligned pointer and undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-5
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Pointers

from Cast cast, VoidPointerType type, PointerToObjectType newType
where
  not isExcluded(cast, Pointers1Package::conversionFromPointerToVoidIntoPointerToObjectQuery()) and
  type = cast.getExpr().getUnderlyingType() and
  newType = cast.getUnderlyingType() and
  not isNullPointerConstant(cast.getExpr())
select cast,
  "Cast performed from a void pointer into a pointer to an object (" + newType.getName() + ")."

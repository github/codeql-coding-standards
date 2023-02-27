/**
 * @id c/misra/pointer-should-point-to-const-type-when-possible
 * @name RULE-8-13: A pointer should point to a const-qualified type whenever possible
 * @description A pointer should point to a const-qualified type unless it is used to modify an
 *              object or the underlying object data is copied.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-8-13
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Pointers
import codingstandards.cpp.SideEffect

from Variable ptr, PointerOrArrayType type
where
  not isExcluded(ptr, Pointers1Package::pointerShouldPointToConstTypeWhenPossibleQuery()) and
  // include only pointers which point to a const-qualified type
  ptr.getType() = type and
  not type.isDeeplyConstBelow() and
  // exclude pointers passed as arguments to functions which take a
  // parameter that points to a non-const-qualified type
  not exists(FunctionCall fc, int i |
    fc.getArgument(i) = ptr.getAnAccess() and
    not fc.getTarget().getParameter(i).getType().isDeeplyConstBelow()
  ) and
  // exclude any pointers which have their underlying data modified
  not exists(VariableEffect effect |
    effect.getTarget() = ptr and
    // but not pointers that are only themselves modified
    not effect.(AssignExpr).getLValue() = effect.getAnAccess() and
    not effect.(CrementOperation).getOperand() = effect.getAnAccess()
  ) and
  // exclude pointers assigned to another pointer to a non-const-qualified type
  not exists(Variable a |
    a.getAnAssignedValue() = ptr.getAnAccess() and
    not a.getType().(PointerOrArrayType).isDeeplyConstBelow()
  )
select ptr, "$@ points to a non-const-qualified type.", ptr, ptr.getName()

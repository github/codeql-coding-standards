/**
 * @id c/misra/modifiable-l-value-subscripted-with-temporary-lifetime
 * @name RULE-18-9: Usage of the subscript operator on an object with temporary lifetime shall not return a modifiable value
 * @description Modifying elements of an array with temporary lifetime will result in undefined
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-18-9
 *       external/misra/c/2012/amendment3
 *       correctness
 *       security
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.lifetimes.CLifetimes

class TemporaryLifetimeArrayExpr extends ArrayExpr {
  TemporaryLifetimeArrayAccess member;
  Type elementType;

  TemporaryLifetimeArrayExpr() {
    member = getArrayBase() and
    elementType = member.getType().(ArrayType).getBaseType()
    or
    exists(TemporaryLifetimeArrayExpr inner |
      inner = getArrayBase() and
      member = inner.getMember() and
      elementType = inner.getElementType().(ArrayType).getBaseType()
    )
  }

  TemporaryLifetimeArrayAccess getMember() { result = member }

  Type getElementType() { result = elementType }
}

predicate usedAsModifiableLvalue(Expr expr) {
  exists(Assignment parent | parent.getLValue() = expr)
  or
  exists(CrementOperation parent | parent.getOperand() = expr)
  or
  exists(AddressOfExpr parent | parent.getOperand() = expr)
  or
  exists(FieldAccess parent | parent.getQualifier() = expr and usedAsModifiableLvalue(parent))
}

from TemporaryLifetimeArrayExpr expr, TemporaryLifetimeArrayAccess member
where
  not isExcluded(expr,
    InvalidMemory3Package::modifiableLValueSubscriptedWithTemporaryLifetimeQuery()) and
  member = expr.getMember() and
  not expr.isUnevaluated() and
  usedAsModifiableLvalue(expr)
select expr,
  "Modifiable lvalue produced by subscripting array member $@ of temporary lifetime object $@ ",
  member, member.getTarget().getName(), member.getTemporary(), member.getTemporary().toString()

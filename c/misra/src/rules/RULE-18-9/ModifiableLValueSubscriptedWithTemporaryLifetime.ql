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
import codingstandards.c.Objects
import codeql.util.Boolean

predicate usedAsModifiableLvalue(Expr expr, Boolean allowArrayAccess) {
  exists(Assignment parent | parent.getLValue() = expr)
  or
  exists(CrementOperation parent | parent.getOperand() = expr)
  or
  exists(AddressOfExpr parent | parent.getOperand() = expr)
  or
  // Don't report `x.y[0].m[0]++` twice. Recurse with `allowArrayAccess` set to false.
  exists(FieldAccess parent |
    parent.getQualifier() = expr and usedAsModifiableLvalue(parent, false)
  )
  or
  allowArrayAccess = true and
  exists(ArrayExpr parent | parent.getArrayBase() = expr and usedAsModifiableLvalue(parent, true))
}

from ArrayExpr expr, FieldAccess fieldAccess, TemporaryObjectIdentity tempObject
where
  not isExcluded(expr,
    InvalidMemory3Package::modifiableLValueSubscriptedWithTemporaryLifetimeQuery()) and
  expr = tempObject.getASubobjectAccess() and
  fieldAccess = expr.getArrayBase() and
  not expr.isUnevaluated() and
  usedAsModifiableLvalue(expr, true)
select expr,
  "Modifiable lvalue produced by subscripting array member $@ of temporary lifetime object $@ ",
  fieldAccess, fieldAccess.getTarget().getName(), tempObject, tempObject.toString()

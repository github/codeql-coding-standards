/**
 * @id c/misra/values-returned-by-locale-setting-used-as-ptr-to-const
 * @name RULE-21-19: The pointers returned by certain functions should be treated as const
 * @description The pointers returned by the Standard Library functions localeconv, getenv,
 *              setlocale or, strerror shall only be used as if they have pointer to const-qualified
 *              type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-19
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

/*
 * Call to functions that return pointers to environment objects that should not be modified.
 */

class NotModifiableCall extends FunctionCall {
  NotModifiableCall() {
    this.getTarget().hasGlobalName(["getenv", "setlocale", "localeconv", "strerror"])
  }
}

predicate isNonConstVar(ControlFlowNode node, Expr e) {
  exists(Variable v |
    exprDefinition(v, node, e) and
    not v.getType().(PointerType).getBaseType().isConst()
  )
}

from Expr e, NotModifiableCall c
where
  not isExcluded(e, Contracts2Package::valuesReturnedByLocaleSettingUsedAsPtrToConstQuery()) and
  (
    isNonConstVar(e, c)
    or
    //argument of non const param
    exists(FunctionCall fc, int n |
      fc = e and
      fc.getChild(n) = c and
      not fc.getTarget().getParameter(n).getType().(DerivedType).getBaseType*().isConst()
    )
    or
    // underlying string is modified
    DataFlow::localExprFlow(c, e) and
    e =
      any(AssignExpr ae).getLValue().(ArrayExpr).getArrayBase().(PointerFieldAccess).getQualifier() and
    e.getType().(PointerType).getBaseType().isConst()
  )
select e,
  "The pointer returned by $@ shell only be used as a pointer to const-qualified type as modifying the pointed object leads to unspecified behavior.",
  c, c.toString()

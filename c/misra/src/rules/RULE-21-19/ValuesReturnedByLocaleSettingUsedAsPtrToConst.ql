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

/*
 * Call to functions that return pointers to environment objects that should not be modified.
 */

class NotModifiableCall extends FunctionCall {
  NotModifiableCall() {
    this.getTarget().hasGlobalName(["getenv", "setlocale", "localeconv", "strerror"])
  }
}

/*
 * Assignment to non-cont variable
 * `char *s1 = setlocale(LC_ALL, 0)`
 */

predicate isNonConstVar(Expr node, Expr e) {
  exists(Variable v |
    exprDefinition(v, node, e) and
    not v.getType().(PointerType).getBaseType().isConst()
  )
}

/*
 * Argument passed to non const function param:
 * `void fun(char *s) {}`
 * `fun(setlocale(LC_ALL, 0));`
 */

predicate isNonConstParam(Expr node, Expr e) {
  exists(FunctionCall fc, int n |
    fc = node and
    fc.getChild(n) = e and
    not fc.getTarget().getParameter(n).getType().(DerivedType).getBaseType*().isConst()
  )
}

/*
 * Underlying string is modified
 * const struct lconv *c = localeconv();
 *  c->grouping[0] = '0';
 */

predicate modifiesInternalString(Expr node, Expr e) {
  DataFlow::localExprFlow(e, node) and
  node =
    any(AssignExpr ae).getLValue().(ArrayExpr).getArrayBase().(PointerFieldAccess).getQualifier() and
  node.getType().(PointerType).getBaseType().isConst()
}

from Expr e, NotModifiableCall c
where
  not isExcluded(e, Contracts2Package::valuesReturnedByLocaleSettingUsedAsPtrToConstQuery()) and
  (
    isNonConstVar(e, c)
    or
    isNonConstParam(e, c)
    or
    modifiesInternalString(e, c)
  )
select e,
  "The pointer returned by $@ shell only be used as a pointer to const-qualified type as modifying the pointed object leads to unspecified behavior.",
  c, c.toString()

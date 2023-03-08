/**
 * @id c/cert/atomic-variable-twice-in-expression
 * @name CON40-C: Do not refer to an atomic variable twice in an expression
 * @description Atomic variables that are referred to twice in the same expression can produce
 *              unpredictable program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con40-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Concurrency

from MacroInvocation mi, Variable v, Locatable whereFound
where
  not isExcluded(whereFound, Concurrency5Package::atomicVariableTwiceInExpressionQuery()) and
  (
    // There isn't a way to safely use this construct in a way that is also
    // possible the reliably detect so advise against using it.
    (
      mi instanceof AtomicStore
      or
      // This construct is generally safe, but must be used in a loop. To lower
      // the false positive rate we don't look at the conditions of the loop and
      // instead assume if it is found in a looping construct that it is likely
      // related to the safety property.
      mi instanceof AtomicCompareExchange and
      not exists(Loop l | mi.getAGeneratedElement().(Expr).getParent*() = l)
    ) and
    whereFound = mi
  )
  or
  mi.getMacroName() = "ATOMIC_VAR_INIT" and
  exists(Expr av |
    av = mi.getAGeneratedElement() and
    av = v.getAnAssignedValue() and
    exists(Assignment m |
      not m instanceof AssignXorExpr and
      m.getLValue().(VariableAccess).getTarget() = v and
      whereFound = m
    )
  )
select mi, "Atomic variable possibly referred to twice in an $@.", whereFound, "expression"

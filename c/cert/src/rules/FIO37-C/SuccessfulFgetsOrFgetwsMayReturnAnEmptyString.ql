/**
 * @id c/cert/successful-fgets-or-fgetws-may-return-an-empty-string
 * @name FIO37-C: Do not assume that fgets() or fgetws() returns a nonempty string when successful
 * @description A string returned by fgets() or fegtws() might be empty.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio37-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.FgetsErrorManagement
import codingstandards.cpp.Dereferenced
import semmle.code.cpp.dataflow.TaintTracking

/*
 * CFG nodes that follows a successful call to `fgets`
 */

ControlFlowNode followsNonnullFgets(FgetsLikeCall fgets) {
  exists(FgetsGuard guard |
    //fgets.getLocation().getStartLine() = [60] and
    fgets = guard.getFgetCall() and
    (
      result = guard.getNonNullSuccessor()
      or
      result = followsNonnullFgets(fgets).getASuccessor()
    )
  )
}

from Expr e, FgetsLikeCall fgets
where
  not isExcluded(e, IO3Package::successfulFgetsOrFgetwsMayReturnAnEmptyStringQuery()) and
  e = followsNonnullFgets(fgets) and
  (
    e instanceof ArrayExpr
    or
    e instanceof PointerDereferenceExpr
  ) and
  not exists(GuardCondition guard |
    guard.controls(e.getBasicBlock(), _) and guard = followsNonnullFgets(fgets)
  )
select e, "The string $@ could be empty when accessed at this location.", fgets.getBuffer(),
  fgets.getBuffer().toString()

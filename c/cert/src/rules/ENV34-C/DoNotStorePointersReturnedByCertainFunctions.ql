/**
 * @id c/cert/do-not-store-pointers-returned-by-certain-functions
 * @name ENV34-C: Do not store pointers returned by certain functions
 * @description The value returned by functions `getenv`, `asctime`, `localeconv`, `setlocale`, and
 *              `strerror` may be overwritten by a second call.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/env34-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow

/*
 * A model of environment functions
 */

class GetenvFunctionCall extends FunctionCall {
  GetenvFunctionCall() {
    this.getTarget().getName() = ["getenv", "asctime", "localeconv", "setlocale", "strerror"]
  }
}

from GetenvFunctionCall fc1, GetenvFunctionCall fc2, VariableAccess e
where
  not isExcluded(e, Contracts2Package::doNotStorePointersReturnedByCertainFunctionsQuery()) and
  // A variable `v` is assigned with `GetenvFunctionCall` return value
  exists(Variable v |
    fc1 = v.getInitializer().getExpr()
    or
    exists(Assignment ae | fc1 = ae.getRValue() and v = ae.getLValue().(VariableAccess).getTarget())
  ) and
  // A second `GetenvFunctionCall`
  fc2 = fc1.getASuccessor+() and
  fc2 != fc1 and
  // The value is is accessed in `e` afer the second `GetenvFunctionCall`
  e = fc2.getASuccessor+() and
  DataFlow::localExprFlow(fc1, e)
select e, "The string $@ may have been overwritten by the second $@.", e, e.toString(), fc2,
  fc2.toString()

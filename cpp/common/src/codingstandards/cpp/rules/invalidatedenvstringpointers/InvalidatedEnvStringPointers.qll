/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow

abstract class InvalidatedEnvStringPointersSharedQuery extends Query { }

Query getQuery() { result instanceof InvalidatedEnvStringPointersSharedQuery }

/*
 * A model of environment functions that shall not be use subsequently
 */

class GetenvFunctionCall extends FunctionCall {
  GetenvFunctionCall() {
    this.getTarget().getName() =
      ["asctime", "ctime", "gmtime", "localtime", "localeconv", "getenv", "setlocale", "strerror"]
  }
}

/*
 * The two called functions shall not be use subsequently
 */

predicate incompatibleCalls(GetenvFunctionCall fc1, GetenvFunctionCall fc2) {
  fc2 != fc1 and
  (
    fc1.getTarget() = fc2.getTarget()
    or
    fc1.getTarget().getName() = ["setlocale", "localeconv"] and
    fc2.getTarget().getName() = ["setlocale", "localeconv"]
  )
}

query predicate problems(
  VariableAccess e, string message, GetenvFunctionCall fc1, string fc1text, GetenvFunctionCall fc2,
  string fc2text
) {
  not isExcluded(e, getQuery()) and
  // A variable `v` is assigned with the `GetenvFunctionCall` return value
  exists(Variable v |
    fc1 = v.getInitializer().getExpr()
    or
    exists(Assignment ae | fc1 = ae.getRValue() and v = ae.getLValue().(VariableAccess).getTarget())
  ) and
  // There is subsequent `GetenvFunctionCall`
  fc2 = fc1.getASuccessor+() and
  // The two calls are incompatible
  incompatibleCalls(fc1, fc2) and
  // The pointer returned by fc1 accessed in `e` afer the second `GetenvFunctionCall`
  DataFlow::localExprFlow(fc1, e) and
  e = fc2.getASuccessor+() and
  message = "This pointer was returned by a $@ and may have been overwritten by the susequent $@." and
  fc1text = fc1.toString() and
  fc2text = fc2.toString()
}

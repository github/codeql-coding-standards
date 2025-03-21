/**
 * Provides a library which includes a `problems` predicate for reporting
 * errors in handling environment string returned by standard library calls
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow

abstract class InvalidatedEnvStringPointersSharedQuery extends Query { }

Query getQuery() { result instanceof InvalidatedEnvStringPointersSharedQuery }

/**
 * A model of environment functions that shall not be use subsequently
 */
class GetenvFunction extends Function {
  GetenvFunction() {
    this.getName() =
      ["asctime", "ctime", "gmtime", "localtime", "localeconv", "getenv", "setlocale", "strerror"]
  }
}

class GetenvFunctionCall extends FunctionCall {
  GetenvFunctionCall() { this.getTarget() instanceof GetenvFunction }
}

/**
 * Indirect call to a `GetenvFunctionCall`
 */
class GetenvIndirectCall extends FunctionCall {
  GetenvFunction f;

  GetenvIndirectCall() { this.getTarget().calls*(f) }

  GetenvFunction getFunction() { result = f }
}

/**
 * The two called functions shall not be use subsequently
 */
predicate incompatibleFunctions(GetenvFunction f1, GetenvFunction f2) {
  f1 = f2
  or
  f1.getName() = ["setlocale", "localeconv"] and
  f2.getName() = ["setlocale", "localeconv"]
  or
  f1.getName() = ["asctime", "ctime"] and
  f2.getName() = ["asctime", "ctime"]
  or
  f1.getName() = ["gmtime", "localtime"] and
  f2.getName() = ["gmtime", "localtime"]
}

query predicate problems(
  VariableAccess e, string message, GetenvFunctionCall fc1, string fc1text, GetenvIndirectCall fc2,
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
  fc1 != fc2 and
  incompatibleFunctions(fc1.getTarget(), fc2.getFunction()) and
  // The pointer returned by fc1 accessed in `e` afer the second `GetenvFunctionCall`
  DataFlow::localExprFlow(fc1, e) and
  e = fc2.getASuccessor+() and
  message = "This pointer was returned by a $@ and may have been overwritten by the susequent $@." and
  fc1text = fc1.toString() and
  fc2text = fc2.toString()
}

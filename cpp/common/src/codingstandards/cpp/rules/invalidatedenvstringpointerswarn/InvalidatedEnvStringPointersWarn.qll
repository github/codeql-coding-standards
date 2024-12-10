/**
 * Provides a library which includes a `problems` predicate for reporting
 * warnings in handling environment string returned by standard library calls
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.rules.invalidatedenvstringpointers.InvalidatedEnvStringPointers as EnvString

abstract class InvalidatedEnvStringPointersWarnSharedQuery extends Query { }

Query getQuery() { result instanceof InvalidatedEnvStringPointersWarnSharedQuery }

class GlobalOrMemberVariable extends Variable {
  GlobalOrMemberVariable() { this instanceof GlobalVariable or this instanceof MemberVariable }
}

query predicate problems(
  EnvString::GetenvFunctionCall fc, string message, GlobalOrMemberVariable v, string vtext
) {
  not isExcluded(fc, getQuery()) and
  // Variable `v` is assigned with the `GetenvFunctionCall` return value
  (
    fc = v.getInitializer().getExpr()
    or
    exists(Assignment ae | fc = ae.getRValue() and v = ae.getLValue().(VariableAccess).getTarget())
  ) and
  vtext = v.toString() and
  message =
    "The value of variable $@ might become invalid after a subsequent call to function `" +
      fc.getTarget().getName() + "`."
}

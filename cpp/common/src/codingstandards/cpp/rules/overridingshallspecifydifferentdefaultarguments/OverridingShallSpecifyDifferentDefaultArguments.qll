/**
 * Provides a library with a `problems` predicate for the following issue:
 * Parameters in an overriding virtual function shall not specify different default
 * arguments.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class OverridingShallSpecifyDifferentDefaultArgumentsSharedQuery extends Query { }

Query getQuery() { result instanceof OverridingShallSpecifyDifferentDefaultArgumentsSharedQuery }

query predicate problems(VirtualFunction f2, string message, VirtualFunction f1, string f1_string) {
  not isExcluded(f2, getQuery()) and
  not isExcluded(f1, getQuery()) and
  f2 = f1.getAnOverridingFunction() and
  exists(Parameter p1, Parameter p2 |
    p1 = f1.getAParameter() and
    p2 = f2.getParameter(p1.getIndex())
  |
    if p1.hasInitializer()
    then
      // if there is no initializer
      not p2.hasInitializer()
      or
      // if there is one and it doesn't match
      not p1.getInitializer().getExpr().getValueText() =
        p2.getInitializer().getExpr().getValueText()
    else
      // if p1 doesn't have an initializer p2 shouldn't either
      p2.hasInitializer()
  ) and
  message = "Overriding function does not have the same default parameters as $@" and
  f1_string = "overridden function"
}

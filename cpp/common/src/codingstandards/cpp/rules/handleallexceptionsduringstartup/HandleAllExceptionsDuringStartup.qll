/**
 * Provides a library with a `problems` predicate for the following issue:
 * Exceptions thrown before main begins executing cannot be caught.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph

abstract class HandleAllExceptionsDuringStartupSharedQuery extends Query { }

Query getQuery() { result instanceof HandleAllExceptionsDuringStartupSharedQuery }

/** A `ThrowingExpr` which occurs in a non-local variable initializer executed before `main()`. */
class PreMainThrowingExpr extends ExceptionThrowingExpr {
  GlobalOrNamespaceVariable gv;

  PreMainThrowingExpr() {
    // Any global or namespace variable is non-local
    this = gv.getInitializer().getExpr().getAChild*()
  }

  GlobalOrNamespaceVariable getNonLocalVariable() { result = gv }
}

query predicate problems(
  PreMainThrowingExpr te, ExceptionFlowNode exceptionSource, ExceptionFlowNode throwingNode,
  string message, GlobalOrNamespaceVariable nonLocalVariable, string nonLocalVariableDesc
) {
  exists(ExceptionType et |
    not isExcluded(te, getQuery()) and
    te.hasExceptionFlow(exceptionSource, throwingNode, et) and
    nonLocalVariable = te.getNonLocalVariable() and
    message =
      "Initializer for variable $@ can throw an exception of type " + et.getExceptionName() +
        " before main begins executing." and
    nonLocalVariableDesc = nonLocalVariable.getName()
  )
}

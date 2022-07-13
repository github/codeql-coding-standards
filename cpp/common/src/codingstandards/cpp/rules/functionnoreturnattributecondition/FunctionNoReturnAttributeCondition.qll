/**
 * Provides a library which includes a `problems` predicate for reporting the functions with 'noreturn' attribute that return.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class FunctionNoReturnAttributeConditionSharedQuery extends Query { }

Query getQuery() { result instanceof FunctionNoReturnAttributeConditionSharedQuery }

/**
 * This checks that the return statement is reachable from the function entry point
 */
query predicate problems(Function f, string message) {
  not isExcluded(f, getQuery()) and
  f.getAnAttribute().getName() = "noreturn" and
  exists(ReturnStmt s |
    f = s.getEnclosingFunction() and
    s.getBasicBlock().isReachable()
  ) and
  message = "The function " + f.getName() + " declared with attribute [[noreturn]] returns a value."
}

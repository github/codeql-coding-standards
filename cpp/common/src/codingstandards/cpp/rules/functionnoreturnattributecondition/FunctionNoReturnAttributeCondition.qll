/**
 * Provides a library which includes a `problems` predicate for reporting the functions with 'noreturn' attribute that return.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Noreturn

abstract class FunctionNoReturnAttributeConditionSharedQuery extends Query { }

Query getQuery() { result instanceof FunctionNoReturnAttributeConditionSharedQuery }

/**
 * `noreturn` functions are declared differently in c/c++. Attempt to match
 * the description to the file; low risk if it chooses incorrectly.
 */
string describeNoreturn(Function f) {
  if f.getFile().getExtension() = ["c", "C", "h", "H"]
  then result = "_Noreturn"
  else result = "[[noreturn]]"
}

/**
 * This checks that the return statement is reachable from the function entry point
 */
query predicate problems(NoreturnFunction f, string message) {
  not isExcluded(f, getQuery()) and
  mayReturn(f) and
  not f.isCompilerGenerated() and
  message =
    "The function " + f.getName() + " declared with attribute " + describeNoreturn(f) +
      " returns a value."
}

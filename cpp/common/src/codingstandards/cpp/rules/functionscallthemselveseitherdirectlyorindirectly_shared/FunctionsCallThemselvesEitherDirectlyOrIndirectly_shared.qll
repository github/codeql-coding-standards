/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class FunctionsCallThemselvesEitherDirectlyOrIndirectly_sharedSharedQuery extends Query { }

Query getQuery() {
  result instanceof FunctionsCallThemselvesEitherDirectlyOrIndirectly_sharedSharedQuery
}

class RecursiveCall extends FunctionCall {
  RecursiveCall() {
    this.getTarget().calls*(this.getEnclosingFunction()) and
    not this.getTarget().hasSpecifier("is_constexpr")
  }
}

query predicate problems(FunctionCall fc, string message, Function f, string f_name) {
  exists(RecursiveCall call |
    not isExcluded(call, getQuery()) and
    f = fc.getTarget() and
    f_name = fc.getTarget().getName() and
    fc.getTarget() = call.getTarget() and
    if fc.getTarget() = fc.getEnclosingFunction()
    then message = "This call directly invokes its containing function $@."
    else
      message =
        "The function " + fc.getEnclosingFunction() +
          " is indirectly recursive via this call to $@."
  )
}

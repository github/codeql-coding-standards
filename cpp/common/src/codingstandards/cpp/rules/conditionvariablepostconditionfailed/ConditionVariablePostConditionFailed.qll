/**
 * Provides a library which includes a `problems` predicate for reporting uses of the
 * `conditional_variable*::wait*()` functions.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ConditionVariablePostConditionFailedSharedQuery extends Query { }

Query getQuery() { result instanceof ConditionVariablePostConditionFailedSharedQuery }

/*
 * This is implemented as an audit query because it flags every use of the conditional_variable*::wait*()
 * functions. Each should be checked to verify that either the postconditions are always guaranteed to hold,
 * or that the consequences of std::terminate being called is acceptable.
 *
 * The specific postconditions are described in `[thread.condition.condvar]` and `[thread.condition.condvarany]`.
 */

/** A call to a `wait` function on `condition_variable` or `condition_variable_any`. */
class ConditionVariableWaitCall extends FunctionCall {
  ConditionVariableWaitCall() {
    getTarget()
        .getDeclaringType()
        .hasQualifiedName("std", ["condition_variable", "condition_variable_any"]) and
    getTarget().getName() = ["wait_for", "wait_until", "wait"]
  }
}

query predicate problems(ConditionVariableWaitCall waitCall, string message) {
  not isExcluded(waitCall, getQuery()) and
  message =
    "[AUDIT] Call to " + waitCall.getTarget().getName() +
      " may call std::terminate if certain postconditions do not hold."
}

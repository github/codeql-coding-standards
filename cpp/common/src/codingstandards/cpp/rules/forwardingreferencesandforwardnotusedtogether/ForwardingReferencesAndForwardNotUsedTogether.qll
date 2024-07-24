/**
 * Provides a library with a `problems` predicate for the following issue:
 * Forwarding references and std::forward shall be used together.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.standardlibrary.Utility

abstract class ForwardingReferencesAndForwardNotUsedTogetherSharedQuery extends Query { }

Query getQuery() { result instanceof ForwardingReferencesAndForwardNotUsedTogetherSharedQuery }

query predicate problems(FunctionCall c, string message, Parameter a, string a_string) {
  not isExcluded(c, getQuery()) and
  a_string = a.getName() and
  a.getAnAccess() = c.getAnArgument() and
  (
    c instanceof StdMoveCall and
    a instanceof ForwardParameter and
    message = "Function `std::forward` should be used for forwarding the forward reference $@."
    or
    c instanceof StdForwardCall and
    a instanceof ConsumeParameter and
    message = "Function `std::move` should be used for forwarding rvalue reference $@."
  )
}

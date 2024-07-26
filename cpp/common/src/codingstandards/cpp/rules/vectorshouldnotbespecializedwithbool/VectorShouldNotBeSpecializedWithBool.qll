/**
 * Provides a library with a `problems` predicate for the following issue:
 * The std::vector<bool> specialization differs from all other containers
 * std::vector<T> such that sizeof bool is implementation defined which causes errors
 * when using some STL algorithms.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.StdNamespace

abstract class VectorShouldNotBeSpecializedWithBoolSharedQuery extends Query { }

Query getQuery() { result instanceof VectorShouldNotBeSpecializedWithBoolSharedQuery }

predicate isVectorBool(ClassTemplateInstantiation c) {
  c.getNamespace() instanceof StdNS and
  c.getTemplateArgument(0) instanceof BoolType and
  c.getSimpleName() = "vector"
}

predicate isUsingVectorBool(ClassTemplateInstantiation c) {
  isVectorBool(c) or
  isUsingVectorBool(c.getTemplateArgument(_))
}

query predicate problems(Variable v, string message) {
  exists(ClassTemplateInstantiation c |
    not isExcluded(v, getQuery()) and
    v.getUnderlyingType() = c and
    not v.isFromTemplateInstantiation(_) and
    isUsingVectorBool(c) and
    message = "Use of std::vector<bool> specialization."
  )
}

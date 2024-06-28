/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.StdNamespace

abstract class VectorShouldNotBeSpecializedWithBool_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof VectorShouldNotBeSpecializedWithBool_sharedSharedQuery }

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

/**
 * Provides a library with a `problems` predicate for the following issue:
 * Function templates shall not be explicitly specialized.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class FunctionTemplatesExplicitlySpecializedSharedQuery extends Query { }

Query getQuery() { result instanceof FunctionTemplatesExplicitlySpecializedSharedQuery }

query predicate problems(
  FunctionTemplateSpecialization f, string message, TemplateFunction tf, string tf_string
) {
  not isExcluded(f, getQuery()) and
  tf = f.getPrimaryTemplate() and
  tf_string = f.getPrimaryTemplate().getFile().getBaseName() and
  message = "Specialization of function template from primary template located in $@."
}

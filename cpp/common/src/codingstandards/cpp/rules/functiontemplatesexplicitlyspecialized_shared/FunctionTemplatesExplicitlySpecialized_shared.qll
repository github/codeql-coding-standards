/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class FunctionTemplatesExplicitlySpecialized_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof FunctionTemplatesExplicitlySpecialized_sharedSharedQuery }

query predicate problems(
  FunctionTemplateSpecialization f, string message, TemplateFunction tf, string tf_string
) {
  not isExcluded(f, getQuery()) and
  tf = f.getPrimaryTemplate() and
  tf_string = f.getPrimaryTemplate().getFile().getBaseName() and
  message = "Specialization of function template from primary template located in $@."
}

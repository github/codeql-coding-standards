/**
 * Provides a library which includes a `problems` predicate for reporting unused types.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.types.Uses

abstract class UnusedTypeDeclarationsSharedQuery extends Query { }

Query getQuery() { result instanceof UnusedTypeDeclarationsSharedQuery }

query predicate problems(UserType ut, string message) {
  not isExcluded(ut, getQuery()) and
  message = "Type declaration " + ut.getName() + " is not used." and
  not ut instanceof TemplateParameter and
  not ut instanceof ProxyClass and
  not exists(getATypeUse(ut)) and
  not ut.isFromUninstantiatedTemplate(_)
}

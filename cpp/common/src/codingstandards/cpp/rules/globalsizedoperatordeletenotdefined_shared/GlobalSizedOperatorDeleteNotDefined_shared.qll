/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.OperatorDelete

abstract class GlobalSizedOperatorDeleteNotDefined_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof GlobalSizedOperatorDeleteNotDefined_sharedSharedQuery }

query predicate problems(OperatorDelete unsized_delete, string message) {
  not isExcluded(unsized_delete, getQuery()) and
  not unsized_delete.isSizeDelete() and
  not exists(OperatorDelete od | unsized_delete.isNoThrowDelete() = od.isNoThrowDelete() |
    od.isSizeDelete()
  ) and
  message =
    "Unsized function '" + unsized_delete.getName() + "' defined globally without sized version."
}

/**
 * Provides a library with a `problems` predicate for the following issue:
 * If a project has the unsized version of operator 'delete' globally defined, then the
 * sized version shall be defined.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.OperatorDelete

abstract class GlobalSizedOperatorDeleteNotDefinedSharedQuery extends Query { }

Query getQuery() { result instanceof GlobalSizedOperatorDeleteNotDefinedSharedQuery }

query predicate problems(OperatorDelete unsized_delete, string message) {
  not isExcluded(unsized_delete, getQuery()) and
  not unsized_delete.isSizeDelete() and
  not exists(OperatorDelete od | unsized_delete.isNoThrowDelete() = od.isNoThrowDelete() |
    od.isSizeDelete()
  ) and
  message =
    "Unsized function '" + unsized_delete.getName() + "' defined globally without sized version."
}

/**
 * Provides a library with a `problems` predicate for the following issue:
 * If a project has the sized version of operator 'delete' globally defined, then the
 * unsized version shall be defined.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.OperatorDelete

abstract class GlobalUnsizedOperatorDeleteNotDefinedSharedQuery extends Query { }

Query getQuery() { result instanceof GlobalUnsizedOperatorDeleteNotDefinedSharedQuery }

query predicate problems(OperatorDelete sized_delete, string message) {
  not isExcluded(sized_delete, getQuery()) and
  sized_delete.isSizeDelete() and
  not exists(OperatorDelete od | sized_delete.isNoThrowDelete() = od.isNoThrowDelete() |
    not od.isSizeDelete()
  ) and
  message =
    "Sized function '" + sized_delete.getName() + "' defined globally without unsized version."
}

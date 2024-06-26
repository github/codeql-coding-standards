/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.OperatorDelete

abstract class GlobalUnsizedOperatorDeleteNotDefined_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof GlobalUnsizedOperatorDeleteNotDefined_sharedSharedQuery }

query predicate problems(OperatorDelete sized_delete, string message) {
  not isExcluded(sized_delete, getQuery()) and
  sized_delete.isSizeDelete() and
  not exists(OperatorDelete od | sized_delete.isNoThrowDelete() = od.isNoThrowDelete() |
    not od.isSizeDelete()
  ) and
  message =
    "Sized function '" + sized_delete.getName() + "' defined globally without unsized version."
}

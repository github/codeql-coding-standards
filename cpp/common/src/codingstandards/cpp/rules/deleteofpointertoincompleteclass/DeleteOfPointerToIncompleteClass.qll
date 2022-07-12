/**
 * Provides a library which includes a `problems` predicate for reporting use of delete on incomplete types.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Type

abstract class DeleteOfPointerToIncompleteClassSharedQuery extends Query { }

Query getQuery() { result instanceof DeleteOfPointerToIncompleteClassSharedQuery }

query predicate problems(
  DeleteExpr deleteExpr, string message, IncompleteType incompleteType, string incompleteTypeName
) {
  not isExcluded(deleteExpr, getQuery()) and
  exists(PointerType pt | pt = deleteExpr.getExpr().getUnderlyingType() |
    pt.getBaseType() = incompleteType and
    incompleteTypeName = incompleteType.getName() and
    message = "Deleting pointer to the incomplete class $@."
  )
}

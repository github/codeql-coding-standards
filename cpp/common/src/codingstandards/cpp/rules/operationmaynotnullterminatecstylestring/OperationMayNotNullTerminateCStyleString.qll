/**
 * Implements a shared library which detects operations that may not result in a
 * null-terminated c-style string.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.models.implementations.StdString
import codingstandards.cpp.PossiblyUnsafeStringOperation

abstract class OperationMayNotNullTerminateCStyleStringSharedQuery extends Query { }

Query getQuery() { result instanceof OperationMayNotNullTerminateCStyleStringSharedQuery }

query predicate problems(PossiblyUnsafeStringOperation op, string message) {
  not isExcluded(op, getQuery()) and
  message = "Operation on a C-style string that may not result in a null-terminated string."
}

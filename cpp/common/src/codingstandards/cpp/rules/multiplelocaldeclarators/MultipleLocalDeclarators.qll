/**
 * Provides a library with a `problems` predicate for the following issue:
 * A declaration should not declare more than one variable or member variable.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class MultipleLocalDeclaratorsSharedQuery extends Query { }

Query getQuery() { result instanceof MultipleLocalDeclaratorsSharedQuery }

query predicate problems(DeclStmt ds, string message) {
  not isExcluded(ds, getQuery()) and
  count(Declaration d | d = ds.getADeclaration()) > 1 and
  // Not a compiler generated `DeclStmt`, such as in the range-based for loop
  not ds.isCompilerGenerated() and
  message = "Declaration list contains more than one declaration."
}

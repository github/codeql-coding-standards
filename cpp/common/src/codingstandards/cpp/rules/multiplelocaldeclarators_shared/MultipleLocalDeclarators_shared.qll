/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class MultipleLocalDeclarators_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof MultipleLocalDeclarators_sharedSharedQuery }

query predicate problems(DeclStmt ds, string message) {
  not isExcluded(ds, getQuery()) and
  count(Declaration d | d = ds.getADeclaration()) > 1 and
  // Not a compiler generated `DeclStmt`, such as in the range-based for loop
  not ds.isCompilerGenerated() and
  message = "Declaration list contains more than one declaration."
}

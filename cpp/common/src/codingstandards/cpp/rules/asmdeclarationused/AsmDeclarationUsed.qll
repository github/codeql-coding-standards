/**
 * Provides a library with a `problems` predicate for the following issue:
 * The asm declaration shall not be used.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class AsmDeclarationUsedSharedQuery extends Query { }

Query getQuery() { result instanceof AsmDeclarationUsedSharedQuery }

query predicate problems(AsmStmt e, string message) {
  not isExcluded(e, getQuery()) and message = "Use of asm declaration"
}

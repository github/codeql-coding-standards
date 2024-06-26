/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class AsmDeclarationUsed_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof AsmDeclarationUsed_sharedSharedQuery }

query predicate problems(AsmStmt e, string message) {
  not isExcluded(e, getQuery()) and message = "Use of asm declaration"
}

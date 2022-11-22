/**
 * Provides a library which includes a `problems` predicate for reporting
 * undocumented uses of assembly.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class UsageOfAssemblerNotDocumentedSharedQuery extends Query { }

Query getQuery() { result instanceof UsageOfAssemblerNotDocumentedSharedQuery }

query predicate problems(AsmStmt a, string message) {
  not isExcluded(a, getQuery()) and
  not exists(Comment c | c.getCommentedElement() = a) and
  not a.isAffectedByMacro() and
  message = "Use of assembler is not documented."
}

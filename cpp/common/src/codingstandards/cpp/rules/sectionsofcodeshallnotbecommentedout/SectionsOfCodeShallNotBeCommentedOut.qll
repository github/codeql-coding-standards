/**
 * Provides a library which includes a `problems` predicate for reporting
 * commented out blocks of code.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.CommentedOutCode

abstract class SectionsOfCodeShallNotBeCommentedOutSharedQuery extends Query { }

Query getQuery() { result instanceof SectionsOfCodeShallNotBeCommentedOutSharedQuery }

query predicate problems(CommentedOutCode comment, string message) {
  not isExcluded(comment, getQuery()) and
  message = "This comment appears to contain commented-out code."
}

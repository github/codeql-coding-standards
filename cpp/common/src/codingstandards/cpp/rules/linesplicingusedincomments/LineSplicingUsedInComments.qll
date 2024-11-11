/**
 * Provides a library with a `problems` predicate for the following issue:
 * Entering a newline following a '\\' character can erroneously commenting out
 * regions of code.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class LineSplicingUsedInCommentsSharedQuery extends Query { }

Query getQuery() { result instanceof LineSplicingUsedInCommentsSharedQuery }

query predicate problems(CppStyleComment c, string message) {
  not isExcluded(c, getQuery()) and
  exists(c.getContents().regexpFind("\\\n", _, _)) and
  message = "C++ comment includes \\ as the last character of a line"
}

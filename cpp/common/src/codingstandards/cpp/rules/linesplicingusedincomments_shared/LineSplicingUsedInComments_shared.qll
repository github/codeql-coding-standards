/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class LineSplicingUsedInComments_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof LineSplicingUsedInComments_sharedSharedQuery }

query predicate problems(CppStyleComment c, string message) {
  not isExcluded(c, getQuery()) and
  exists(c.getContents().regexpFind("\\\n", _, _)) and
  message = "C++ comment includes \\ as the last character of a line"
}

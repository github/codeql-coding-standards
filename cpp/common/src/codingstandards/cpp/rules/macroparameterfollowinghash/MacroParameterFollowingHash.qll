/**
 * Provides a library with a `problems` predicate for the following issue:
 * A macro parameter immediately following a # operator shall not be immediately
 * followed by a ## operator.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Macro

abstract class MacroParameterFollowingHashSharedQuery extends Query { }

Query getQuery() { result instanceof MacroParameterFollowingHashSharedQuery }

query predicate problems(Macro m, string message) {
  not isExcluded(m, getQuery()) and
  exists(StringizingOperator one, TokenPastingOperator two |
    one.getMacro() = m and
    two.getMacro() = m and
    one.getOffset() < two.getOffset()
  ) and
  message = "Macro definition uses an # operator followed by a ## operator."
}

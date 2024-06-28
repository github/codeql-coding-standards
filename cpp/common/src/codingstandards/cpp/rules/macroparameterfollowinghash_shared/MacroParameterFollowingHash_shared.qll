/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Macro

abstract class MacroParameterFollowingHash_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof MacroParameterFollowingHash_sharedSharedQuery }

query predicate problems(Macro m, string message) {
  not isExcluded(m, getQuery()) and
  exists(StringizingOperator one, TokenPastingOperator two |
    one.getMacro() = m and
    two.getMacro() = m and
    one.getOffset() < two.getOffset()
  ) and
  message = "Macro definition uses an # operator followed by a ## operator."
}

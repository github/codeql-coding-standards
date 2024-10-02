/**
 * Provides a library with a `problems` predicate for the following issue:
 * The macro offsetof shall not be used.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class MacroOffsetofUsedSharedQuery extends Query { }

Query getQuery() { result instanceof MacroOffsetofUsedSharedQuery }

query predicate problems(MacroInvocation mi, string message) {
  not isExcluded(mi, getQuery()) and
  mi.getMacroName() = "offsetof" and
  message = "Use of banned macro " + mi.getMacroName() + "."
}

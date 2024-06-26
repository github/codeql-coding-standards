/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class MacroOffsetofUsed_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof MacroOffsetofUsed_sharedSharedQuery }

query predicate problems(MacroInvocation mi, string message) {
  not isExcluded(mi, getQuery()) and
  mi.getMacroName() = "offsetof" and
  message = "Use of banned macro " + mi.getMacroName() + "."
}

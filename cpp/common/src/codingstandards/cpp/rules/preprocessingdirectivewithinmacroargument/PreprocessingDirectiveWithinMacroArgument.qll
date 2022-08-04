/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.PreprocessorDirective

abstract class PreprocessingDirectiveWithinMacroArgumentSharedQuery extends Query { }

Query getQuery() { result instanceof PreprocessingDirectiveWithinMacroArgumentSharedQuery }

query predicate problems(MacroInvocation m, string message) {
  not isExcluded(m, getQuery()) and
  exists(PreprocessorDirective p |
    p = isLocatedInAMacroInvocation(m) and
    message =
      "Invocation of macro " + m.getMacroName() + " includes a token \"" + p +
        "\" that could be confused for an argument preprocessor directive."
  )
}

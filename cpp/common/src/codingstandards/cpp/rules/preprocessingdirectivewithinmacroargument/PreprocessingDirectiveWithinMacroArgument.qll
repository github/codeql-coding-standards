/**
 * Provides a library with a `problems` predicate for the following issue:
 * Arguments to a function-like macro shall not contain tokens that look like
 * pre-processing directives or else behaviour after macro expansion is unpredictable.
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

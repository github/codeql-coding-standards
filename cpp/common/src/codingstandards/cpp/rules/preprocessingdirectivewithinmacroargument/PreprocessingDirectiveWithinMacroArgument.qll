/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class PreprocessingDirectiveWithinMacroArgumentSharedQuery extends Query { }

Query getQuery() { result instanceof PreprocessingDirectiveWithinMacroArgumentSharedQuery }

pragma[noinline]
predicate isMacroInvocationLocation(MacroInvocation mi, File f, int startChar, int endChar) {
  mi.getActualLocation().charLoc(f, startChar, endChar)
}

pragma[noinline]
predicate isPreprocDirectiveLocation(PreprocessorDirective pd, File f, int startChar) {
  pd.getLocation().charLoc(f, startChar, _)
}

query predicate problems(MacroInvocation m, string message) {
  not isExcluded(m, getQuery()) and
  exists(PreprocessorDirective p |
    // There is not sufficient information in the database for nested macro invocations, because
    // the location of nested macros and preprocessor directives are all set to the location of the
    // outermost macro invocation
    not exists(m.getParentInvocation()) and
    exists(File f, int startChar, int endChar |
      isMacroInvocationLocation(m, f, startChar, endChar) and
      exists(int lStart | isPreprocDirectiveLocation(p, f, lStart) |
        // If the start location of the preprocessor directive is after the start of the macro
        // invocation, and before the end, it must be within the macro invocation
        // Note: it's critical to use startChar < lStart, not startChar <= lStart, because the
        // latter will include preprocessor directives which occur in nested macro invocations
        startChar < lStart and lStart < endChar
      )
    ) and
    message =
      "Invocation of macro " + m.getMacroName() + " includes a token \"" + p +
        "\" that could be confused for an argument preprocessor directive."
  )
}

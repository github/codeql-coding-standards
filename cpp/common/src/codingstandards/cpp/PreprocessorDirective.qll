import cpp
import codingstandards.cpp.Macro

pragma[noinline]
predicate isPreprocDirectiveLocation(PreprocessorDirective pd, File f, int startChar) {
  pd.getLocation().charLoc(f, startChar, _)
}

pragma[noinline]
predicate isPreprocDirectiveLine(PreprocessorDirective pd, File f, int startline, int endline) {
  pd.getLocation().hasLocationInfo(f.getAbsolutePath(), startline, _, endline, _)
}

PreprocessorDirective isLocatedInAMacroInvocation(MacroInvocation m) {
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
    result = p
  )
}

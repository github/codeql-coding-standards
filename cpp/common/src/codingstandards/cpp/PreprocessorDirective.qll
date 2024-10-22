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

/**
 * An `if` or `elif` preprocessor branch.
 */
class PreprocessorIfOrElif extends PreprocessorBranch {
  PreprocessorIfOrElif() {
    this instanceof PreprocessorIf or
    this instanceof PreprocessorElif
  }
}

/**
 * Holds if the preprocessor directive `m` is located at `filepath` and `startline`.
 */
pragma[noinline]
predicate hasPreprocessorLocation(PreprocessorDirective m, string filepath, int startline) {
  m.getLocation().hasLocationInfo(filepath, startline, _, _, _)
}

/**
 * Holds if `first` and `second` are a pair of branch directives in the same file, such that they
 * share the same root if condition.
 */
pragma[noinline]
private predicate isBranchDirectivePair(
  PreprocessorBranchDirective first, PreprocessorBranchDirective second, string filepath,
  int b1StartLocation, int b2StartLocation
) {
  first.getIf() = second.getIf() and
  not first = second and
  hasPreprocessorLocation(first, filepath, b1StartLocation) and
  hasPreprocessorLocation(second, filepath, b2StartLocation) and
  b1StartLocation < b2StartLocation
}

/**
 * Holds if `bd` is a branch directive in the range `filepath`, `startline`, `endline`.
 */
pragma[noinline]
predicate isBranchDirectiveRange(
  PreprocessorBranchDirective bd, string filepath, int startline, int endline
) {
  hasPreprocessorLocation(bd, filepath, startline) and
  exists(PreprocessorBranchDirective next |
    next = bd.getNext() and
    // Avoid referencing filepath here, otherwise the optimiser will try to join
    // on it
    hasPreprocessorLocation(next, _, endline)
  )
}

/**
 * Holds if the macro `m` is defined within the branch directive `bd`.
 */
pragma[noinline]
predicate isMacroDefinedWithinBranch(PreprocessorBranchDirective bd, Macro m) {
  exists(string filepath, int startline, int endline, int macroline |
    isBranchDirectiveRange(bd, filepath, startline, endline) and
    hasPreprocessorLocation(m, filepath, macroline) and
    startline < macroline and
    endline > macroline
  )
}

/**
 * Holds if the pair of macros are "conditional" i.e. only one of the macros is followed in any
 * particular compilation of the containing file.
 */
predicate mutuallyExclusiveBranchDirectiveMacros(Macro firstMacro, Macro secondMacro) {
  exists(PreprocessorBranchDirective b1, PreprocessorBranchDirective b2 |
    isBranchDirectivePair(b1, b2, _, _, _) and
    isMacroDefinedWithinBranch(b1, firstMacro) and
    isMacroDefinedWithinBranch(b2, secondMacro)
  )
}

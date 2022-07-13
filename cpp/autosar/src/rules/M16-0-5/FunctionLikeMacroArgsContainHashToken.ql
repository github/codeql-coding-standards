/**
 * @id cpp/autosar/function-like-macro-args-contain-hash-token
 * @name M16-0-5: Arguments to a function-like macro shall not contain tokens that look like pre-processing directives
 * @description Arguments to a function-like macro shall not contain tokens that look like
 *              pre-processing directives or else behaviour after macro expansion is unpredictable.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-0-5
 *       readability
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

pragma[noinline]
predicate isMacroInvocationLocation(MacroInvocation mi, File f, int startChar, int endChar) {
  mi.getActualLocation().charLoc(f, startChar, endChar)
}

pragma[noinline]
predicate isPreprocDirectiveLocation(PreprocessorDirective pd, File f, int startChar) {
  pd.getLocation().charLoc(f, startChar, _)
}

from MacroInvocation m, PreprocessorDirective p
where
  not isExcluded(m, MacrosPackage::functionLikeMacroArgsContainHashTokenQuery()) and
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
  )
select m,
  "Invocation of macro " + m.getMacroName() +
    " includes a $@ that could be confused for an argument", p, "preprocessor directive"

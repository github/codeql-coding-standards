/**
 * @id cpp/autosar/include-guards-not-provided
 * @name M16-2-3: Include guards shall be provided
 * @description Using anything other than a standard include guard form can make code confusing and
 *              can lead to multiple or conflicting definitions.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-2-3
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

pragma[noinline]
predicate isPreprocFileAndLine(Element pd, string filepath, int startLine) {
  pd.getLocation().hasLocationInfo(filepath, startLine, _, _, _)
}

pragma[noinline]
predicate isPreprocConditionalRange(
  PreprocessorBranch pb, string filepath, int startLine, int endLine
) {
  exists(PreprocessorEndif end | pb.getEndIf() = end |
    isPreprocFileAndLine(pb, filepath, startLine) and
    isPreprocFileAndLine(end, filepath, endLine)
  )
}

class GuardMacro extends Macro {
  GuardMacro() {
    //wrapper #ifndef present for use as include guard
    //and they only suffice if there are no non comment elements above them
    exists(PreprocessorIfndef wrapper |
      getAGuard(this) = wrapper and
      not exists(Element above, string filepath, int aboveStartLine, int ifdefStartLine |
        aboveStartLine < ifdefStartLine and
        isPreprocFileAndLine(wrapper, filepath, ifdefStartLine) and
        isPreprocFileAndLine(above, filepath, aboveStartLine) and
        not (above instanceof Comment or above instanceof File)
      )
    )
  }
}

/**
 * An optimised version of `PreprocessorBranchDirective.getAGuard()`.
 */
private PreprocessorBranch getAGuard(Element guardedElement) {
  exists(string filepath, int ifStartLine, int guardedElementStartLine, int endifStartLine |
    isPreprocConditionalRange(result, filepath, ifStartLine, endifStartLine) and
    isPreprocFileAndLine(guardedElement, filepath, guardedElementStartLine) and
    ifStartLine < guardedElementStartLine and
    guardedElementStartLine < endifStartLine
  )
}

from File file
where
  not exists(GuardMacro guard | guard.getFile() = file) and
  //headers are anything included
  exists(Include i | i.getIncludedFile() = file) and
  not isExcluded(file, IncludesPackage::includeGuardsNotProvidedQuery())
select file, "Header file $@ is missing expected include guard.", file, file.getBaseName()

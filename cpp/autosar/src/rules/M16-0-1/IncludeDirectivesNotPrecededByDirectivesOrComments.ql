/**
 * @id cpp/autosar/include-directives-not-preceded-by-directives-or-comments
 * @name M16-0-1: #include directives in a file shall only be preceded by other pre-processor directives or comments
 * @description Using anything other than other pre-processor directives or comments before an
 *              '#include' directive makes the code more difficult to read.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-0-1
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class PreprocessorBranchMacroAccess extends MacroAccess {
  PreprocessorBranchMacroAccess() {
    // We're only interested in cases in the users source code
    exists(getFile().getRelativePath()) and
    exists(PreprocessorBranchDirective pd, string filepath, int startline |
      pd.getLocation().hasLocationInfo(filepath, startline, _, _, _) and
      getLocation().hasLocationInfo(filepath, startline, _, _, _)
    )
  }
}

class NotIncludeOrCommentElement extends Element {
  NotIncludeOrCommentElement() {
    exists(getFile().getRelativePath()) and
    not (
      this instanceof PreprocessorDirective or
      this instanceof Comment or
      this instanceof File or
      this instanceof PreprocessorBranchMacroAccess
    )
  }
}

from NotIncludeOrCommentElement first, Include second
where
  exists(string filepath, int firststartline, int secondstartline |
    first.getLocation().hasLocationInfo(filepath, firststartline, _, _, _) and
    second.getLocation().hasLocationInfo(filepath, secondstartline, _, _, _) and
    firststartline < secondstartline
  ) and
  not isExcluded(second, MacrosPackage::includeDirectivesNotPrecededByDirectivesOrCommentsQuery())
select second, second + " is preceded by a non-preprocessor or comment code element."

import cpp
import codingstandards.cpp.Exclusions

abstract class PreprocessorIncludesPrecededSharedQuery extends Query { }

Query getQuery() { result instanceof PreprocessorIncludesPrecededSharedQuery }

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

query predicate problems(Include second, string message) {
  exists(NotIncludeOrCommentElement first |
    exists(string filepath, int firststartline, int secondstartline |
      first.getLocation().hasLocationInfo(filepath, firststartline, _, _, _) and
      second.getLocation().hasLocationInfo(filepath, secondstartline, _, _, _) and
      firststartline < secondstartline
    ) and
    not isExcluded(second, getQuery()) and
    message = second + " is preceded by a non-preprocessor or comment code element."
  )
}

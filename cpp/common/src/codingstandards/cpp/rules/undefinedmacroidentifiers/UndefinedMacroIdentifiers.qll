import cpp
import codingstandards.cpp.Exclusions
import codingstandards.cpp.PreprocessorDirective

abstract class UndefinedMacroIdentifiersSharedQuery extends Query { }

Query getQuery() { result instanceof UndefinedMacroIdentifiersSharedQuery }

pragma[noinline]
predicate isMacroAccessFileAndLine(MacroAccess ma, string filepath, int startLine) {
  ma.getLocation().hasLocationInfo(filepath, startLine, _, _, _)
}

pragma[noinline]
predicate isPreprocFileAndLine(PreprocessorBranchDirective pd, string filepath, int startLine) {
  pd.getLocation().hasLocationInfo(filepath, startLine, _, _, _)
}

/**
 * A `MacroAccess` that occurs in a `PreprocessorBranchDirective`.
 *
 * Example:
 * ```
 * #if FOO_BAR != 30
 * ...
 * ```
 */
class PreprocessorBranchMacroAccess extends MacroAccess {
  PreprocessorBranch pd;

  PreprocessorBranchMacroAccess() {
    // We're only interested in cases in the users source code
    exists(getFile().getRelativePath()) and
    // There must a be a `PreprocessorBranch` that occurs in the same file, and on the
    // same line
    exists(string filepath, int startLine |
      // Extracted to improve join order
      isPreprocFileAndLine(pd, filepath, startLine) and
      isMacroAccessFileAndLine(this, filepath, startLine)
    )
  }

  PreprocessorBranch getBranchDirective() { result = pd }
}

/**
 * An optimised version of `PreprocessorBranchDirective.getAGuard()`.
 */
private PreprocessorBranch getAGuard(PreprocessorBranch pb) {
  exists(
    PreprocessorEndif end, string filepath, int guardStartLine, int pbStartLine, int endifStartLine
  |
    result.getEndIf() = end
  |
    isPreprocFileAndLine(result, filepath, guardStartLine) and
    isPreprocFileAndLine(pb, filepath, pbStartLine) and
    isPreprocFileAndLine(end, filepath, endifStartLine) and
    guardStartLine < pbStartLine and
    pbStartLine < endifStartLine
  )
}

/** Gets a macro identifier which is #ifdef checked in `pb`. */
string getAnIfDefdMacroIdentifier(PreprocessorBranch pb) {
  exists(string portion |
    portion =
      pb.getHead()
          .replaceAll("\\", " ")
          .replaceAll("(", " ")
          .replaceAll(")", " ")
          .splitAt("&&")
          .splitAt("||") and
    result = portion.regexpCapture("^.*defined\\s*\\(?\\s*([a-zA-Z_][0-9a-zA-Z_]*)\\s*\\)?.*$", 1)
    or
    portion = "" and
    pb.(PreprocessorIfdef).getHead() = result
  )
}

class UndefinedIdIfOrElif extends PreprocessorIfOrElif {
  string undefinedMacroIdentifier;

  UndefinedIdIfOrElif() {
    exists(string defRM |
      defRM =
        this.getHead()
            .regexpReplaceAll("__has_(attribute|cpp_attribute|c_attribute|builtin|include)\\s*\\(\\s*[0-9a-zA-Z_:]*\\s*\\)",
              "")
            .regexpReplaceAll("defined\\s*\\(?\\s*[a-zA-Z_][0-9a-zA-Z_]*\\s*\\)?", "") and
      undefinedMacroIdentifier = defRM.regexpFind("(?<![_a-zA-Z0-9])[_a-zA-Z][_a-zA-Z0-9]*", _, _) and
      // No corresponding MacroAccess for this branch directive
      not exists(PreprocessorBranchMacroAccess m |
        this = m.getBranchDirective() and
        m.getMacro().getName() = undefinedMacroIdentifier
      ) and
      // Not checked for defined in the same file
      not exists(PreprocessorBranch thisOrGuard |
        thisOrGuard = getAGuard(this)
        or
        thisOrGuard = this
      |
        undefinedMacroIdentifier = getAnIfDefdMacroIdentifier(thisOrGuard)
      )
    )
  }

  string getAnUndefinedMacroIdentifier() { result = undefinedMacroIdentifier }
}

query predicate problems(UndefinedIdIfOrElif b, string message) {
  not isExcluded(b, getQuery()) and
  message =
    "#if/#elif that uses a macro identifier " + b.getAnUndefinedMacroIdentifier() +
      " that may be undefined."
}

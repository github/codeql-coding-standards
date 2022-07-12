/**
 * @id cpp/autosar/undefined-macro-identifiers-used-in
 * @name M16-0-7: Undefined macro identifiers shall not be used in #if or #elif pre-processor directives, except as operands to the defined operator
 * @description Using undefined macro identifiers in #if or #elif pre-processor directives, except
 *              as operands to the defined operator, can cause the code to be hard to understand
 *              because the preprocessor will just treat the value as 0 and no warning is given.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m16-0-7
 *       correctness
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

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

class IfAndElifs extends PreprocessorBranch {
  IfAndElifs() {
    this instanceof PreprocessorIf or
    this instanceof PreprocessorElif
  }
}

class BadIfAndElifs extends IfAndElifs {
  string undefinedMacroIdentifier;

  BadIfAndElifs() {
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

from BadIfAndElifs b
where not isExcluded(b, MacrosPackage::undefinedMacroIdentifiersUsedInQuery())
select b,
  "#if/#elif that uses a macro identifier " + b.getAnUndefinedMacroIdentifier() +
    " that may be undefined."

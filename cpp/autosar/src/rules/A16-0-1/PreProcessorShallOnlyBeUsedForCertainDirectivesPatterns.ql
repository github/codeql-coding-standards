/**
 * @id cpp/autosar/pre-processor-shall-only-be-used-for-certain-directives-patterns
 * @name A16-0-1: The pre-processor shall only be used for unconditional and conditional file inclusion and include
 * @description The pre-processor shall only be used for unconditional and conditional file
 *              inclusion and include guards, and using the following directives: (1) #ifndef,
 *              #ifdef, (3) #if, (4) #if defined, (5) #elif, (6) #else, (7) #define, (8) #endif, (9)
 *              #include.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a16-0-1
 *       maintainability
 *       readability
 *       external/autosar/strict
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.FunctionLikeMacro

class PermittedDirectiveType extends PreprocessorDirective {
  PermittedDirectiveType() {
    //permissive listing in case directive types modelled in ql ever expands (example non valid directives)
    this instanceof MacroWrapper or
    this instanceof PreprocessorEndif or
    this instanceof Include or
    this instanceof PermittedMacro
  }
}

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

class PermittedMacro extends Macro {
  PermittedMacro() {
    //wrapper #ifndef present for use as include guard
    exists(PreprocessorIfndef wrapper | getAGuard(this) = wrapper)
  }
}

class MacroWrapper extends PreprocessorIfndef {
  //wrapper #ifndef present for use as include guard
  MacroWrapper() { exists(PermittedMacro wrapped | getAGuard(wrapped) = this) }
}

class AcceptableWrapper extends PreprocessorBranch {
  AcceptableWrapper() {
    forall(Element inner | not inner instanceof Comment and this = getAGuard(inner) |
      inner instanceof PermittedDirectiveType
    )
  }
}

from PreprocessorDirective directive, string message
where
  //special exception case - pragmas already reported by A16-7-1
  not directive instanceof PreprocessorPragma and
  not directive instanceof PermittedDirectiveType and
  not directive instanceof AcceptableWrapper and
  message = "Preprocessor directive used for conditional compilation." and
  not isExcluded(directive,
    MacrosPackage::preProcessorShallOnlyBeUsedForCertainDirectivesPatternsQuery())
select directive, message

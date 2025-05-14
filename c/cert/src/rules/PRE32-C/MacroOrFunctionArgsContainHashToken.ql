/**
 * @id c/cert/macro-or-function-args-contain-hash-token
 * @name PRE32-C: Do not use preprocessor directives in invocations of function-like macros
 * @description Arguments to a function-like macros shall not contain tokens that look like
 *              pre-processing directives or else behaviour after macro expansion is unpredictable.
 *              This rule applies to functions as well in case they are implemented using macros.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/pre32-c
 *       correctness
 *       readability
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.PreprocessorDirective

pragma[noinline]
predicate isFunctionInvocationLocation(FunctionCall call, File f, int startline, int endline) {
  call.getLocation().hasLocationInfo(f.getAbsolutePath(), startline, _, _, _) and
  isFunctionSuccessorLocation(call.getASuccessor(), f, endline)
}

pragma[noinline]
predicate isFunctionSuccessorLocation(ControlFlowNode node, File f, int endline) {
  //for all function calls the closest location heurisitc we have for end line is the next node in cfg
  node.getLocation().hasLocationInfo(f.getAbsolutePath(), endline, _, _, _)
}

PreprocessorDirective isLocatedInAFunctionInvocation(FunctionCall c) {
  exists(PreprocessorDirective p, File f, int startCall, int endCall |
    isFunctionInvocationLocation(c, f, startCall, endCall) and
    exists(Expr arg, int preprocStartLine, int preprocEndLine |
      c.getAnArgument() = arg and
      isPreprocDirectiveLine(p, f, preprocStartLine, preprocEndLine) and
      // function call begins before preprocessor directive
      startCall < preprocStartLine and
      (
        // argument's location is after the preprocessor directive
        arg.getLocation().getStartLine() > preprocStartLine
        or
        // arg's location is before an endif token that is part of a
        // preprocessor directive defined before the argument.
        // E.g.
        // memcpy(dest, src,
        // #ifdef SOMEMACRO
        // 12
        // #else
        // 24 // 'arg' exists here
        // #endif // endif after 'arg', but part of a preproc. branch before 'arg'
        // );
        p instanceof PreprocessorEndif and
        // exists a preprocessor branch of which this is the endif
        // and that preprocessor directive exists before
        // the argument and after the function call begins.
        exists(PreprocessorBranchDirective another |
          another.getEndIf() = p and
          another.getLocation().getFile() = f and
          startCall < another.getLocation().getStartLine() and
          arg.getLocation().getStartLine() > another.getLocation().getStartLine()
        )
      ) and
      // function call ends after preprocessor directive
      endCall > preprocEndLine
    ) and
    result = p
  )
}

from PreprocessorDirective p, string msg
where
  not isExcluded(p, Preprocessor5Package::macroOrFunctionArgsContainHashTokenQuery()) and
  exists(FunctionCall c |
    p = isLocatedInAFunctionInvocation(c) and
    //if this is actually a function in a macro ignore it because it will still be seen in the macro condition
    not c.isInMacroExpansion() and
    msg =
      "Invocation of function " + c.getTarget().getName() + " includes a token \"" + p +
        "\" that could be confused for an argument preprocessor directive."
  )
  or
  exists(MacroInvocation m |
    p = isLocatedInAMacroInvocation(m) and
    msg =
      "Invocation of macro " + m.getMacroName() + " includes a token \"" + p +
        "\" that could be confused for an argument preprocessor directive."
  )
select p, msg

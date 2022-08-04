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
    exists(int startLine, int endLine | isPreprocDirectiveLine(p, f, startLine, endLine) |
      startCall < startLine and
      startCall < endLine and
      endLine <= endCall and
      endLine <= endCall
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

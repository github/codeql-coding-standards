/**
 * @id cpp/cert/do-not-throw-an-exception-across-execution-boundaries
 * @name ERR59-CPP: Do not throw an exception across execution boundaries
 * @description The execution boundary is between the call site in the executable and the function
 *              implementation in the library.  Throwing an exception across an execution boundary
 *              requires that both sides of the execution boundary use the same application binary
 *              interface.  Throw an exception across an execution boundary only when both sides of
 *              the boundary use the same application binary interface.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err59-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p12
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.UnhandledExceptions
import codingstandards.cpp.Operator

string getCompiler(Compilation c) {
  exists(int mimicPos |
    c.getArgument(mimicPos) = "--mimic" and
    result = c.getArgument(mimicPos + 1) and
    not result = "@-" // exclude response files
  )
}

from
  FunctionCall call, Function f, Expr throws, ExceptionType exceptionType,
  Compilation callingCompilation, Compilation calledCompilation
where
  call.getTarget() = f and
  exceptionType = getAFunctionThrownType(f, throws) and
  callingCompilation.getAFileCompiled() = call.getFile() and
  calledCompilation.getAFileCompiled() = f.getFile() and
  not getCompiler(callingCompilation) = getCompiler(calledCompilation)
select f, "Function $@ an exception of type $@ and is $@ across execution boundaries.", throws,
  "throws", exceptionType, exceptionType.getExceptionName(), call, "called"

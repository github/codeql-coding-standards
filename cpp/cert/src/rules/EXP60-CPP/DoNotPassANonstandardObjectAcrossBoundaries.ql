/**
 * @id cpp/cert/do-not-pass-a-nonstandard-object-across-boundaries
 * @name EXP60-CPP: Do not pass a nonstandard-layout type object across execution boundaries
 * @description The execution boundary is between the call site in the executable and the function
 *              implementation in the library.  Standard layout objects can be passed across
 *              execution boundaries because the layout of the object's type is strictly specified.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp60-cpp
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

string getCompiler(Compilation c) {
  exists(int mimicPos |
    c.getArgument(mimicPos) = "--mimic" and
    result = c.getArgument(mimicPos + 1) and
    not result = "@-" // exclude response files
  )
}

from FunctionCall call, Class c, Compilation callComp, Compilation implComp, Function f
where
  not c.isStandardLayout() and
  call.getAnArgument().getUnspecifiedType().stripType() = c and
  call.getTarget() = f and
  f.getFile() = implComp.getAFileCompiled() and
  call.getFile() = callComp.getAFileCompiled() and
  not getCompiler(callComp) = getCompiler(implComp)
select call,
  "Nonstandard class $@ is used as an argument to function $@, which is compiled differently than its implementation $@",
  c, "Class", call, "Function Call", f, "Function Implementation"

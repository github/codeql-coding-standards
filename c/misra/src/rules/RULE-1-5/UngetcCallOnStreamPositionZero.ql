/**
 * @id c/misra/ungetc-call-on-stream-position-zero
 * @name RULE-1-5: Disallowed obsolescent usage of 'ungetc' on a file stream at position zero
 * @description Calling the function 'ungetc' on a file stream with a position of zero is an
 *              obsolescent language feature.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-1-5
 *       external/misra/c/2012/amendment3
 *       security
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.controlflow.Dominance
import codingstandards.c.misra

/**
 * This is an inconclusive list, which is adequate, as RULE-21-3 provides
 * assurance we won't have false negatives, or care too much about false
 * positives.
 */
class MoveStreamPositionCall extends FunctionCall {
  Expr streamArgument;

  MoveStreamPositionCall() {
    getTarget().hasGlobalOrStdName("fgetc") and
    streamArgument = getArgument(0)
    or
    getTarget().hasGlobalOrStdName("getc") and
    streamArgument = getArgument(0)
    or
    getTarget().hasGlobalOrStdName("fget") and
    streamArgument = getArgument(2)
    or
    getTarget().hasGlobalOrStdName("fscanf") and
    streamArgument = getArgument(0)
    or
    getTarget().hasGlobalOrStdName("fsetpos") and
    streamArgument = getArgument(0)
    or
    getTarget().hasGlobalOrStdName("fseek") and
    streamArgument = getArgument(0)
    or
    getTarget().hasGlobalOrStdName("fread") and
    streamArgument = getArgument(3)
  }

  Expr getStreamArgument() { result = streamArgument }
}

from FunctionCall ungetc, DataFlow::Node file
where
  not isExcluded(ungetc, Language4Package::ungetcCallOnStreamPositionZeroQuery()) and
  // ungetc() called on file stream
  ungetc.getTarget().hasGlobalOrStdName("ungetc") and
  DataFlow::localFlow(file, DataFlow::exprNode(ungetc.getArgument(1))) and
  // ungetc() is not dominated by a fread() etc to that file stream
  not exists(MoveStreamPositionCall moveStreamCall |
    DataFlow::localFlow(file, DataFlow::exprNode(moveStreamCall.getStreamArgument())) and
    dominates(moveStreamCall, ungetc)
  )
  // the file stream is the root of the local data flow
  and not DataFlow::localFlow(any(DataFlow::Node n | not n = file), file)
select ungetc, "Obsolescent call to ungetc on file stream $@ at position zero.", file,
  file.toString()

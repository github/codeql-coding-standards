/**
 * @id c/misra/ungetc-call-on-stream-position-zero
 * @name RULE-1-5: Disallowed obsolescent usage of 'ungetc' on a file stream at position zero
 * @description Calling the function 'ungetc' on a file stream with a position of zero is an
 *              obsolescent language feature.
 * @kind path-problem
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

module FilePositionZeroFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    node.asIndirectExpr().(FunctionCall).getTarget().hasGlobalOrStdName("fopen")
  }

  predicate isSink(DataFlow::Node node) {
    exists(FunctionCall fc |
      fc.getTarget().hasGlobalOrStdName("ungetc") and
      node.asIndirectExpr() = fc.getArgument(1)
    )
  }

  predicate isBarrierIn(DataFlow::Node node) {
    exists(MoveStreamPositionCall fc | node.asIndirectExpr() = fc.getStreamArgument())
  }
}

module FilePositionZeroFlow = DataFlow::Global<FilePositionZeroFlowConfig>;

import FilePositionZeroFlow::PathGraph

from FilePositionZeroFlow::PathNode sink, FilePositionZeroFlow::PathNode source
where
  not isExcluded(sink.getNode().asExpr(), Language4Package::ungetcCallOnStreamPositionZeroQuery()) and
  FilePositionZeroFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "Obsolescent call to ungetc on file stream $@ at position zero.", source, source.toString()

/**
 * @id c/misra/attempt-to-write-to-a-read-only-stream
 * @name RULE-22-4: There shall be no attempt to write to a stream which has been opened as read-only
 * @description Attempting to write on a read-only stream is undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-4
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.standardlibrary.FileAccess
import semmle.code.cpp.dataflow.DataFlow

class FileDFConf extends DataFlow::Configuration {
  FileDFConf() { this = "FileDFConf" }

  override predicate isSource(DataFlow::Node source) {
    // source is the return value of a call to fopen
    source.asExpr().(FOpenCall).isReadOnlyMode()
  }

  override predicate isSink(DataFlow::Node sink) {
    // sink must be the second parameter of a FsetposCall call
    sink.asExpr() = any(FileWriteFunctionCall write).getFileExpr()
  }
}

from FileDFConf dfConf, DataFlow::Node source, FileWriteFunctionCall sink
where
  not isExcluded(sink, IO3Package::attemptToWriteToAReadOnlyStreamQuery()) and
  dfConf.hasFlow(source, DataFlow::exprNode(sink.getFileExpr()))
select sink, "Attempt to write to a $@ opened as read-only.", source, "stream"

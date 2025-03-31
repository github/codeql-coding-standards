/**
 * @id c/cert/possibly-predictable-temporary-file-creation
 * @name FIO21-C: Do not use predictably generated temporary file paths
 * @description Hardcoded or predictably generated temporary file paths can be hijacked or
 *              manipulated by an attacker if not created in a secure manner.
 * @kind path-problem
 * @precision medium
 * @problem.severity warning
 * @tags external/cert/id/fio21-c
 *       security
 *       external/cert/obligation/recommendation
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.TaintTracking

module TempDirTaintConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    node.asExpr().(StringLiteral).getValue().matches(["/var/tmp/%", "/tmp/%", "C:\\\\Temp\\\\%"])
  }

  predicate isSink(DataFlow::Node node) {
    exists(FunctionCall fc | fc.getArgument(0) = node.asExpr())
  }
}

module TempDirTaint = TaintTracking::Global<TempDirTaintConfig>;

import TempDirTaint::PathGraph

from FunctionCall fc, string message, TempDirTaint::PathNode source, TempDirTaint::PathNode sink
where
  not isExcluded(fc, IO5Package::possiblyPredictableTemporaryFileCreationQuery()) and
  fc.getTarget().hasName("fopen") and
  sink.getNode() = DataFlow::exprNode(fc.getArgument(0)) and
  TempDirTaint::flow(source.getNode(), sink.getNode()) and
  message = "Possible unsafe temporary file creation using 'fopen'."
select fc, source, sink, "Possible unsafe temporary file creation using 'fopen'."

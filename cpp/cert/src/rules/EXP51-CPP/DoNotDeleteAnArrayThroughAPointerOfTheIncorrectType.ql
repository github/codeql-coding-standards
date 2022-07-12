/**
 * @id cpp/cert/do-not-delete-an-array-through-a-pointer-of-the-incorrect-type
 * @name EXP51-CPP: Do not delete an array through a pointer of the incorrect type
 * @description Deleting an array through a pointer of an incorrect type leads to undefined
 *              behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp51-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

class AllocationToDeleteConfig extends DataFlow::Configuration {
  AllocationToDeleteConfig() { this = "AllocationToDelete" }

  override predicate isSource(DataFlow::Node source) { source.asExpr() instanceof NewArrayExpr }

  override predicate isSink(DataFlow::Node sink) {
    exists(DeleteArrayExpr dae | dae.getExpr() = sink.asExpr())
  }
}

from
  AllocationToDeleteConfig config, DataFlow::PathNode source, DataFlow::PathNode sink,
  NewArrayExpr newArray, DeleteArrayExpr deleteArray
where
  not isExcluded(deleteArray.getExpr(),
    FreedPackage::doNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeQuery()) and
  config.hasFlowPath(source, sink) and
  newArray = source.getNode().asExpr() and
  deleteArray.getExpr() = sink.getNode().asExpr() and
  not newArray.getType().getUnspecifiedType() = deleteArray.getExpr().getType().getUnspecifiedType()
select sink, source, sink,
  "Array of type " + newArray.getType() + " is deleted through a pointer of type " +
    deleteArray.getExpr().getType() + "."

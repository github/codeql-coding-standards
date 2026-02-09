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
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import semmle.code.cpp.dataflow.DataFlow
import AllocationToDeleteFlow::PathGraph

module AllocationToDeleteConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source.asExpr() instanceof NewArrayExpr }

  predicate isSink(DataFlow::Node sink) {
    exists(DeleteArrayExpr dae | dae.getExpr() = sink.asExpr())
  }
}

module AllocationToDeleteFlow = DataFlow::Global<AllocationToDeleteConfig>;

from
  AllocationToDeleteFlow::PathNode source, AllocationToDeleteFlow::PathNode sink,
  NewArrayExpr newArray, DeleteArrayExpr deleteArray
where
  not isExcluded(deleteArray.getExpr(),
    FreedPackage::doNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeQuery()) and
  AllocationToDeleteFlow::flowPath(source, sink) and
  newArray = source.getNode().asExpr() and
  deleteArray.getExpr() = sink.getNode().asExpr() and
  not newArray.getType().getUnspecifiedType() = deleteArray.getExpr().getType().getUnspecifiedType()
select sink, source, sink,
  "Array of type " + newArray.getType() + " is deleted through a pointer of type " +
    deleteArray.getExpr().getType() + "."

/**
 * Provides a configurable module DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeShared
 * with a `problems` predicate for the following issue:
 * Deleting an array through a pointer of an incorrect type leads to undefined behavior.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow

signature module DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeSharedConfigSig {
  Query getQuery();
}

module DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeShared<
  DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeSharedConfigSig Config>
{
  private module AllocationToDeleteConfig implements DataFlow::ConfigSig {
    predicate isSource(DataFlow::Node source) { source.asExpr() instanceof NewArrayExpr }

    predicate isSink(DataFlow::Node sink) {
      exists(DeleteArrayExpr dae | dae.getExpr() = sink.asExpr())
    }
  }

  module AllocationToDeleteFlow = DataFlow::Global<AllocationToDeleteConfig>;

  module PathGraph = AllocationToDeleteFlow::PathGraph;

  query predicate problems(
    Expr deleteExpr, AllocationToDeleteFlow::PathNode source, AllocationToDeleteFlow::PathNode sink,
    string message
  ) {
    exists(NewArrayExpr newArray, DeleteArrayExpr deleteArray |
      not isExcluded(deleteArray.getExpr(), Config::getQuery()) and
      AllocationToDeleteFlow::flowPath(source, sink) and
      newArray = source.getNode().asExpr() and
      deleteArray.getExpr() = sink.getNode().asExpr() and
      not newArray.getType().getUnspecifiedType() =
        deleteArray.getExpr().getType().getUnspecifiedType() and
      deleteExpr = sink.getNode().asExpr() and
      message =
        "Array of type '" + newArray.getType() + "' is deleted through a pointer of type '" +
          deleteArray.getExpr().getType() + "'."
    )
  }
}

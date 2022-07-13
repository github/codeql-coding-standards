/**
 * Provides a library which includes a `problems` predicate for reporting calls to placement new
 * expressions with insufficient storage.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.allocations.PlacementNew
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

abstract class PlacementNewInsufficientStorageSharedQuery extends Query { }

Query getQuery() { result instanceof PlacementNewInsufficientStorageSharedQuery }

query predicate problems(
  PlacementNewExpr placementNew, DataFlow::PathNode source, DataFlow::PathNode sink, string message,
  PlacementNewMemoryOrigin memoryOrigin, string memoryOriginDescription
) {
  not isExcluded(placementNew, getQuery()) and
  message =
    "Placement new expression is used with an insufficiently large memory allocation from $@." and
  exists(PlacementNewOriginConfig config |
    memoryOrigin = source.getNode() and
    placementNew.getPlacementExpr() = sink.getNode().asExpr() and
    memoryOriginDescription = memoryOrigin.toString() and
    config.hasFlowPath(source, sink) and
    memoryOrigin.getMaximumMemorySize() < placementNew.getMinimumAllocationSize()
  )
}

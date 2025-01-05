/**
 * Provides a library which includes a `problems` predicate for reporting calls to placement new
 * expressions without proper alignment.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.allocations.PlacementNew
import semmle.code.cpp.dataflow.DataFlow
import PlacementNewOriginFlow::PathGraph

abstract class PlacementNewNotProperlyAlignedSharedQuery extends Query { }

Query getQuery() { result instanceof PlacementNewNotProperlyAlignedSharedQuery }

/*
 * "C++ also has very specific mechanics about how arrays of char (and only char are allocated. A new char[*], for example, will not be aligned to the alignment of char."
 */

query predicate problems(
  PlacementNewExpr placementNew, PlacementNewOriginFlow::PathNode source,
  PlacementNewOriginFlow::PathNode sink, string message, PlacementNewMemoryOrigin memoryOrigin,
  string memoryOriginDescription
) {
  not isExcluded(placementNew, getQuery()) and
  memoryOrigin = source.getNode() and
  placementNew.getPlacementExpr() = sink.getNode().asExpr() and
  memoryOriginDescription = memoryOrigin.toString() and
  PlacementNewOriginFlow::flowPath(source, sink) and
  exists(int originAlignment |
    originAlignment = memoryOrigin.getAlignment() and
    // The origin alignment should be exactly divisible by the placement alignment
    (originAlignment / placementNew.getAllocatedType().getAlignment()).ceil() = 0 and
    message = "Placement new expression is used with inappropriately aligned memory from $@."
  )
}

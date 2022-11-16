/**
 * @id c/cert/do-not-cast-pointer-to-more-strictly-aligned-pointer-type
 * @name EXP36-C: Do not cast pointers into more strictly aligned pointer types
 * @description Converting a pointer to a different type results in undefined behavior if the
 *              pointer is not correctly aligned for the new type.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp36-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Alignment
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import DataFlow::PathGraph

/**
 * An expression with a type that has defined alignment requirements
 */
abstract class ExprWithAlignment extends Expr {
  /**
   * Gets the alignment requirements in bytes for the underlying `Expr`
   */
  abstract int getAlignment();

  /**
   * Gets a descriptive string describing the type of expression
   */
  abstract string getKind();
}

/**
 * A class extending `AddressOfExpr` and `ExprWithAlignment` to reason about the
 * alignment of base types addressed with C address-of expressions
 */
class AddressOfAlignedVariableExpr extends AddressOfExpr, ExprWithAlignment {
  AddressOfAlignedVariableExpr() { this.getAddressable() instanceof Variable }

  AlignAs alignAsAttribute() { result = this.getAddressable().(Variable).getAnAttribute() }

  override int getAlignment() {
    result = alignAsAttribute().getArgument(0).getValueInt()
    or
    result = alignAsAttribute().getArgument(0).getValueType().getSize()
    or
    not exists(alignAsAttribute()) and
    result = this.getAddressable().(Variable).getType().getAlignment()
  }

  override string getKind() { result = "address-of expression" }
}

/**
 * A class extending `FunctionCall` and `ExprWithAlignment` to reason about the
 * alignment of pointers allocated with calls to C standard library allocation functions
 */
class DefinedAlignmentAllocationExpr extends FunctionCall, ExprWithAlignment {
  int alignment;

  DefinedAlignmentAllocationExpr() {
    this.getTarget().getName() = "aligned_alloc" and
    lowerBound(this.getArgument(0)) = upperBound(this.getArgument(0)) and
    alignment = upperBound(this.getArgument(0))
    or
    this.getTarget().getName() = ["malloc", "calloc", "realloc"] and
    alignment = getGlobalMaxAlignT()
  }

  override int getAlignment() { result = alignment }

  override string getKind() { result = "call to " + this.getTarget().getName() }
}

/**
 * A class extending `VariableAccess` and `ExprWithAlignment` to reason about the
 * alignment of pointers accessed based solely on the pointers' base types.
 */
class DefaultAlignedPointerAccessExpr extends VariableAccess, ExprWithAlignment {
  DefaultAlignedPointerAccessExpr() {
    this.getTarget().getUnspecifiedType() instanceof PointerType and
    not this.getTarget().getUnspecifiedType() instanceof VoidPointerType
  }

  override int getAlignment() {
    result = this.getTarget().getType().(PointerType).getBaseType().getAlignment()
  }

  override string getKind() { result = "pointer base type" }
}

/**
 * A data-flow configuration for analysing the flow of `ExprWithAlignment` pointer expressions
 * to casts which perform pointer type conversions and potentially create pointer alignment issues.
 */
class ExprWithAlignmentToCStyleCastConfiguration extends DataFlow::Configuration {
  ExprWithAlignmentToCStyleCastConfiguration() {
    this = "ExprWithAlignmentToCStyleCastConfiguration"
  }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof ExprWithAlignment
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(CStyleCast cast |
      cast.getUnderlyingType() instanceof PointerType and
      cast.getUnconverted() = sink.asExpr()
    )
  }
}

/**
 * A data-flow configuration for tracking flow from `AddressOfExpr` which provide
 * most reliable or explicitly defined alignment information to the less reliable
 * `DefaultAlignedPointerAccessExpr` expressions.
 *
 * This data-flow configuration is used
 * to exclude an `DefaultAlignedPointerAccessExpr` as a source if a preceding source
 * defined by this configuration provides more accurate alignment information.
 */
class AllocationOrAddressOfExprToDefaultAlignedPointerAccessConfig extends DataFlow::Configuration {
  AllocationOrAddressOfExprToDefaultAlignedPointerAccessConfig() {
    this = "AllocationOrAddressOfExprToDefaultAlignedPointerAccessConfig"
  }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof AddressOfAlignedVariableExpr or
    source.asExpr() instanceof DefinedAlignmentAllocationExpr
  }

  override predicate isSink(DataFlow::Node sink) {
    sink.asExpr() instanceof DefaultAlignedPointerAccessExpr
  }
}

from
  DataFlow::PathNode source, DataFlow::PathNode sink, ExprWithAlignment expr, CStyleCast cast,
  Type toBaseType, int alignmentFrom, int alignmentTo
where
  not isExcluded(cast, Pointers3Package::doNotCastPointerToMoreStrictlyAlignedPointerTypeQuery()) and
  any(ExprWithAlignmentToCStyleCastConfiguration config).hasFlowPath(source, sink) and
  source.getNode().asExpr() = expr and
  sink.getNode().asExpr() = cast.getUnconverted() and
  (
    // possibility 1: the source node (ExprWithAlignment) is NOT a DefaultAlignedPointerAccessExpr
    // meaning that its alignment info is accurate regardless of any preceding ExprWithAlignment nodes
    expr instanceof DefaultAlignedPointerAccessExpr
    implies
    (
      // possibility 2: the source node (ExprWithAlignment) IS a DefaultAlignedPointerAccessExpr
      // meaning that its alignment info is only accurate if no preceding ExprWithAlignment nodes exist
      not any(AllocationOrAddressOfExprToDefaultAlignedPointerAccessConfig config)
          .hasFlowTo(source.getNode()) and
      expr instanceof DefaultAlignedPointerAccessExpr and
      cast.getUnconverted() instanceof VariableAccess
    )
  ) and
  toBaseType = cast.getActualType().(PointerType).getBaseType() and
  alignmentTo = toBaseType.getAlignment() and
  alignmentFrom = expr.getAlignment() and
  // only flag cases where the cast's target type has stricter alignment requirements than the source
  alignmentFrom < alignmentTo
select sink, source, sink,
  "Cast from pointer with " + alignmentFrom +
    "-byte alignment (defined by $@) to pointer with base type " + toBaseType.getUnderlyingType() +
    " with " + alignmentTo + "-byte alignment.", expr.getUnconverted(), expr.getKind()

/**
 * @id c/cert/do-not-access-variable-via-pointer-of-incompatible-type
 * @name EXP39-C: Do not access a variable through a pointer of an incompatible type
 * @description Modifying underlying pointer data through a pointer of an incompatible type can lead
 *              to unpredictable results.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp39-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.Dominance
import DataFlow::PathGraph

/**
 * The standard function `memset` and its assorted variants
 */
class MemsetFunction extends Function {
  MemsetFunction() {
    this.hasGlobalOrStdOrBslName("memset")
    or
    this.hasGlobalOrStdName("wmemset")
    or
    this.hasGlobalName(["__builtin_memset", "__builtin___memset_chk", "__builtin_memset_chk"])
  }
}

class IndirectCastAnalysisUnconvertedCastExpr extends Expr {
  IndirectCastAnalysisUnconvertedCastExpr() { this = any(Cast c).getUnconverted() }
}

class IndirectCastAnalysisDereferenceSink extends Expr {
  IndirectCastAnalysisDereferenceSink() { dereferenced(this) }
}

class ReallocationFunction extends AllocationFunction {
  ReallocationFunction() { exists(this.getReallocPtrArg()) }
}

/**
 * A data-flow state for a pointer which has not been reallocated.
 */
class IndirectCastDefaultFlowState extends DataFlow::FlowState {
  IndirectCastDefaultFlowState() { this = "IndirectCastDefaultFlowState" }
}

/**
 * A data-flow state for a pointer which has been reallocated but
 * has not yet been zeroed with a memset call.
 */
class IndirectCastReallocatedFlowState extends DataFlow::FlowState {
  IndirectCastReallocatedFlowState() { this = "IndirectCastReallocatedFlowState" }
}

/**
 * A data-flow configuration to track the flow from cast expressions to either
 * other cast expressions or to dereferences of pointers reallocated with a call
 * to `realloc` but not cleared via a function call to `memset`.
 */
class IndirectCastConfiguration extends DataFlow::Configuration {
  IndirectCastConfiguration() { this = "CastToIncompatibleTypeConfiguration" }

  override predicate isSource(DataFlow::Node source, DataFlow::FlowState state) {
    state instanceof IndirectCastDefaultFlowState and
    source.asExpr() instanceof IndirectCastAnalysisUnconvertedCastExpr
  }

  override predicate isSink(DataFlow::Node sink, DataFlow::FlowState state) {
    sink.asExpr() instanceof IndirectCastAnalysisUnconvertedCastExpr and
    state instanceof IndirectCastDefaultFlowState
    or
    sink.asExpr() instanceof IndirectCastAnalysisDereferenceSink and
    state instanceof IndirectCastReallocatedFlowState and
    // The memset call won't always have an edge to subsequent dereferences.
    //
    // Therefore, check that:
    // 1) The memset call dominates the dereference.
    // 2) The realloc call dominates the memset call.
    // 3) There is no subsequent memset that also dominates the dereference.
    //
    // Currently, there is no relation between the pointer passed to memset
    // and the pointer dereferenced. This unimplemented check might produce
    // false-negatives when the memset call is unrelated to the reallocated memory.
    not exists(FunctionCall memset, FunctionCall realloc, Expr ptr |
      memset.getTarget() instanceof MemsetFunction and
      realloc.getTarget() instanceof ReallocationFunction and
      ptr = sink.asExpr() and
      dominates(memset, ptr) and
      not dominates(memset,
        any(FunctionCall other |
          other.getTarget() instanceof MemsetFunction and
          other != memset and
          dominates(other, ptr)
        |
          other
        )) and
      dominates(realloc, memset)
    )
  }

  override predicate isBarrier(DataFlow::Node node, DataFlow::FlowState state) {
    state instanceof IndirectCastReallocatedFlowState and
    exists(FunctionCall fc |
      fc.getTarget() instanceof MemsetFunction and
      fc.getArgument(0) = node.asExpr()
    )
  }

  override predicate isAdditionalFlowStep(
    DataFlow::Node node1, DataFlow::FlowState state1, DataFlow::Node node2,
    DataFlow::FlowState state2
  ) {
    // track pointer flow through realloc calls and update state to `IndirectCastReallocatedFlowState`
    state1 instanceof IndirectCastDefaultFlowState and
    state2 instanceof IndirectCastReallocatedFlowState and
    exists(FunctionCall fc |
      fc.getTarget() instanceof ReallocationFunction and
      node1.asExpr() = fc.getArgument(fc.getTarget().(ReallocationFunction).getReallocPtrArg()) and
      node2.asExpr() = fc
    )
    or
    // track pointer flow through memset calls and reset state to `IndirectCastDefaultFlowState`
    state1 instanceof IndirectCastReallocatedFlowState and
    state2 instanceof IndirectCastDefaultFlowState and
    exists(FunctionCall fc |
      fc.getTarget() instanceof MemsetFunction and
      node1.asExpr() = fc.getArgument(0) and
      node2.asExpr() = fc
    )
  }
}

pragma[inline]
predicate areTypesSameExceptForConstSpecifiers(Type a, Type b) {
  a.stripType() = b.stripType() and
  a.getSize() = b.getSize() and
  forall(Specifier s | s = a.getASpecifier() and not s.hasName("const") |
    b.hasSpecifier(s.getName())
  )
}

pragma[inline]
Type compatibleTypes(Type type) {
  not (
    type.isVolatile() and not result.isVolatile()
    or
    type.isConst() and not result.isConst()
  ) and
  (
    (
      // all types are compatible with void and explicitly-unsigned char types
      result instanceof UnsignedCharType or
      [result.stripTopLevelSpecifiers(), type.stripTopLevelSpecifiers()] instanceof VoidType
    )
    or
    not result instanceof UnsignedCharType and
    not result instanceof VoidType and
    (
      type.stripType() instanceof Struct and
      type.getUnspecifiedType() = result.getUnspecifiedType() and
      not type.getName() = "struct <unnamed>" and
      not result.getName() = "struct <unnamed>"
      or
      not type.stripType() instanceof Struct and
      (
        areTypesSameExceptForConstSpecifiers(type, result)
        or
        result.getSize() = type.getSize() and
        (
          type instanceof Enum and result instanceof IntegralOrEnumType
          or
          not type instanceof PlainCharType and
          (
            result.(IntegralType).isSigned() and type.(IntegralType).isSigned()
            or
            result.(IntegralType).isUnsigned() and type.(IntegralType).isUnsigned()
          )
          or
          result.(FloatingPointType).getDomain() = type.(FloatingPointType).getDomain()
        )
        or
        type instanceof Enum and result instanceof IntegralOrEnumType
      )
    )
  )
}

from DataFlow::PathNode source, DataFlow::PathNode sink, Cast cast, Type fromType, Type toType
where
  not isExcluded(sink.getNode().asExpr(),
    Pointers3Package::doNotAccessVariableViaPointerOfIncompatibleTypeQuery()) and
  cast.getFile().compiledAsC() and
  any(IndirectCastConfiguration config).hasFlowPath(source, sink) and
  // include only sinks which are not a compatible type to the associated source
  source.getNode().asExpr() = cast.getUnconverted() and
  fromType = cast.getUnconverted().getType().(PointerType).getBaseType() and
  toType = sink.getNode().asExpr().getActualType().(PointerType).getBaseType() and
  not toType = compatibleTypes(fromType)
select sink.getNode().asExpr().getUnconverted(), source, sink,
  "Cast from " + fromType + " to " + toType + " results in an incompatible pointer base type."

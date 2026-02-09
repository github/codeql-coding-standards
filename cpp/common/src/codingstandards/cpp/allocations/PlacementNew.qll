/**
 * A module to support analysis of placement new expressions in C++.
 *
 * The module provides a `PlacementNewExpr` class which identifies new expressions which use the
 * placement new operator. Access to the placement argument is provided through the member
 * predicate `getPlacementExpr`.
 *
 * The module also provides support for identifying _origins_ of the placement argument, and
 * reasoning about those origins. We use a global data flow config (`PlacementNewOriginConfig`) to
 * find origins. We consider the following possible origins:
 *
 *  1. Taking the address of an expression.
 *  2. An access of an array stack variable.
 *  3. A static cast from a pointer to a type to void *.
 *  4. A call to heap allocation function.
 *  5. An array access or pointer arithmetic expression.
 *
 * For each origin, we provide a `getMaximumMemorySize`, which identifies the maximum size of the
 * memory pointed to by the pointer (if it can be determined statically), and a `getAlignment`,
 * which provides the alignment of the pointer to memory (if it can be determined statically).
 */

import cpp
import codingstandards.cpp.Conversion
import semmle.code.cpp.dataflow.DataFlow

/*
 * TODO You can also have alignas on types
 * TODO align(...) function returns a pointer alinged on the given boundaries
 * TODO Add std::aligned_storage<sizeof(long), alignof(long)>::type buffer; as an origin, and boost aligned_storage
 * TODO Integrate range analysis into both the allocated size for placement new, and for the origin size
 * TODO consider which compiler is used to determine cookie size. For example, on clang/gcc cookie size is 4 bytes
 *      (sizeof(size_t))
 */

/**
 * A placement new expression.
 */
class PlacementNewExpr extends NewOrNewArrayExpr {
  PlacementNewExpr() { this.getAllocatorCall().getTarget().getNumberOfParameters() > 1 }

  /** Gets the placement expression. */
  Expr getPlacementExpr() { result = getAllocatorCall().getArgument(1) }

  /**
   * Gets the minimum amount of memory required by the placement.
   *
   * For non-array allocations, this is the size of the allocated type. However, allocating an array
   * usually requires more space than just the elements themselves. Compilers will typically add a
   * "cookie" on the front which stores the number of elements so that the delete can call the
   * appropriate number of destructors. The amount of space added is implementation dependent, so
   * we use the size of the allocated type (if possible) and include 1 byte as the minimum which we
   * assume is required for the cookie overhead.
   */
  int getMinimumAllocationSize() {
    result = this.(NewArrayExpr).getAllocatedType().getSize() + 1
    or
    result = this.(NewExpr).getAllocatedType().getSize()
  }
}

/**
 * Gets the alignment of the given `Variable`.
 */
int getVariableAlignment(Variable v) {
  if v.getAnAttribute() instanceof AlignAs
  then result = v.getAnAttribute().(AlignAs).getArgument(0).getValueInt()
  else result = v.getType().getAlignment()
}

/** A data flow node representing the origin of a pointer used with placement new. */
abstract class PlacementNewMemoryOrigin extends DataFlow::Node {
  /** Gets the maximum size of the memory specified by this origin. */
  abstract float getMaximumMemorySize();

  /** Gets the alignment for the memory origin, if it can be determined. */
  abstract int getAlignment();
}

/** An address of expression that provides a pointer for placement new. */
class AddressOfPlacementNewOrigin extends PlacementNewMemoryOrigin {
  AddressOfExpr aoe;

  AddressOfPlacementNewOrigin() { this.asExpr() = aoe }

  override float getMaximumMemorySize() { result = aoe.getOperand().getType().getSize() }

  override int getAlignment() {
    // If this is an access of a variable, we can determine the original alignment of the variable
    // otherwise it's unknown
    result = getVariableAlignment(aoe.getOperand().(VariableAccess).getTarget())
  }
}

/** An stack allocated array whose address provides a pointer for placement new. */
class ArrayInitPlacementNewOrigin extends PlacementNewMemoryOrigin {
  LocalVariable arrayVariable;

  ArrayInitPlacementNewOrigin() {
    arrayVariable.getType() instanceof ArrayType and
    this.asExpr() = arrayVariable.getAnAccess()
  }

  override float getMaximumMemorySize() {
    result = arrayVariable.getType().(ArrayType).getByteSize()
  }

  override int getAlignment() { result = getVariableAlignment(arrayVariable) }
}

/** An static cast expression that provides a pointer for placement new. */
class StaticCastPlacementNewOrigin extends PlacementNewMemoryOrigin {
  StaticOrCStyleCast cast;

  StaticCastPlacementNewOrigin() { this.asExpr() = cast.getExpr() }

  override float getMaximumMemorySize() {
    result = cast.getExpr().getType().getUnspecifiedType().(PointerType).getBaseType().getSize()
  }

  override int getAlignment() {
    // We don't know the origin of the pointer before the cast, so we can't deduce anything about
    // the alignment of the memory it points to
    none()
  }
}

/** A heap allocaion expression that provides a pointer for placement new. */
class AllocationExprPlacementNewOrigin extends PlacementNewMemoryOrigin {
  AllocationExpr alloc;

  AllocationExprPlacementNewOrigin() {
    this.asExpr() = alloc and not alloc instanceof PlacementNewExpr
  }

  override float getMaximumMemorySize() {
    // TODO use range analysis if there isn't a constant size
    result = alloc.getSizeBytes()
  }

  override int getAlignment() {
    // Assuming this `AllocationExpr` is allocating memory via an "allocation function" as specified
    // by [basic.stc.dynamic.allocation], the returned pointer must be "suitably aligned so that it
    // can be converted to a pointer of any complete object type with fundamental alignment
    // requirement". A "fundamental alignment" (according to [basic.align]) is "represented by an
    // alignment less than or equal to the greatest alignment supported by the implementation in all
    // contexts, which is equal to `alignof(std::max_align_t)`".
    //
    // Essentially, this says that allocation functions should return memory that is suitably
    // aligned for any type with alignment requirements below an implementation defined limit.
    // We don't have the implementation defined limit here, so we can't determine what that
    // alignment number would be.
    none()
  }
}

/**
 * A data flow configuration that identifies the origin of the placement argument to a placement
 * new expression.
 */
module PlacementNewOriginConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof PlacementNewMemoryOrigin }

  predicate isSink(DataFlow::Node sink) {
    sink.asExpr() = any(PlacementNewExpr pne).getPlacementExpr()
    // TODO direct calls to placement operator new?
  }

  predicate isAdditionalFlowStep(DataFlow::Node stepFrom, DataFlow::Node stepTo) {
    // Slightly surprisingly, we can't see the `StaticOrCStyleCast`s as a source out-of-the-box with data
    // flow - it's only reported under taint tracking. We therefore add a step through static
    // casts so that we can see them as sources.
    stepTo.asExpr().(StaticOrCStyleCast).getExpr() = stepFrom.asExpr()
  }
}

module PlacementNewOriginFlow = DataFlow::Global<PlacementNewOriginConfig>;

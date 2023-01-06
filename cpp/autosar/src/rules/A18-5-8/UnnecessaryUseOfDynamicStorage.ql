/**
 * @id cpp/autosar/unnecessary-use-of-dynamic-storage
 * @name A18-5-8: Objects that do not outlive a function shall have automatic storage duration
 * @description Creating objects with automatic storage duration implies that there is no additional
 *              allocation and deallocation cost, which would occur when using dynamic storage.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a18-5-8
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.cpp.standardlibrary.Utility

/*
 * The strategy for this query is to find dynamic allocation where the object is both allocated and
 * deallocated in the same function. The object must also be a suitable size to be stored on the
 * stack.
 */

/**
 * An expression which allocates memory on the heap and is a candidate for being only used during
 * the lifetime of the enclosing function.
 */
abstract class CandidateFunctionLocalHeapAllocationExpr extends Expr {
  abstract int getHeapSizeBytes();

  abstract predicate isAlwaysFreed();

  abstract string getObjectName();
}

/** A call to `make_shared` or `make_unique` that heap allocates. */
class MakeSharedOrUnique extends FunctionCall, CandidateFunctionLocalHeapAllocationExpr {
  MakeSharedOrUnique() {
    this.getTarget().hasQualifiedName(["bsl", "std"], ["make_shared", "make_unique"])
  }

  override int getHeapSizeBytes() {
    // Look at the size of the type being created
    result = getTarget().getTemplateArgument(0).(Type).getSize()
  }

  override predicate isAlwaysFreed() {
    // Not copied, moved or forwarded, i.e. by calling it as a function argument
    // This includes the case where a result of `make_shared` or `make_unique` is return by a function
    // because the compiler will call the appropriate constructor.
    not exists(FunctionCall fc | DataFlow::localExprFlow(this, fc.getAnArgument())) and
    // Not assigned to a field
    not exists(Field f | DataFlow::localExprFlow(this, f.getAnAssignedValue()))
  }

  override string getObjectName() { result = getTarget().getTemplateArgument(0).(Type).getName() }
}

/**
 * An `AllocationExpr` that allocates heap memory, where the memory is freed on at least one path
 * through the enclosing function.
 */
class AllocationExprFunctionLocal extends CandidateFunctionLocalHeapAllocationExpr instanceof AllocationExpr {
  AllocationExprFunctionLocal() {
    this.getSizeBytes() < 1024 and
    TaintTracking::localExprTaint(this, any(DeallocationExpr de).getFreedExpr())
  }

  override int getHeapSizeBytes() { result = super.getSizeBytes() }

  DeallocationExpr getADeallocation() { TaintTracking::localExprTaint(this, result.getFreedExpr()) }

  override predicate isAlwaysFreed() {
    not reachableWithoutFree(this) = this.getEnclosingFunction().getBasicBlock()
  }

  private Type getConvertedType() { result = this.getFullyConverted().getType() }

  override string getObjectName() {
    if getConvertedType() instanceof PointerType
    then
      exists(string suffix |
        // Pretty print array types with "[]" suffix
        if this instanceof NewArrayExpr or getType().getUnspecifiedType() instanceof ArrayType
        then suffix = "[]"
        else suffix = ""
      |
        result = getConvertedType().(PointerType).getBaseType().getName() + suffix
      )
    else result = this.getConvertedType().getName()
  }
}

/** Holds if the `BasicBlock` is reachable from the given `AllocationExpr` without being freed. */
private BasicBlock reachableWithoutFree(AllocationExprFunctionLocal ae) {
  result = ae.getBasicBlock() and
  not result = ae.getADeallocation().getBasicBlock()
  or
  exists(BasicBlock mid |
    mid = reachableWithoutFree(ae) and
    result = mid.getASuccessor() and
    not result = ae.getADeallocation().getBasicBlock()
  )
}

from CandidateFunctionLocalHeapAllocationExpr ae
where
  not isExcluded(ae, AllocationsPackage::unnecessaryUseOfDynamicStorageQuery()) and
  // anything less than 1kb is a candidate for stack allocation
  ae.getHeapSizeBytes() < 1024 and
  // Is always freed in this function
  ae.isAlwaysFreed()
select ae,
  ae.getObjectName() + " object of size " + ae.getHeapSizeBytes() +
    " bytes does not appear to outlive the function, but is created on the heap instead of the stack."

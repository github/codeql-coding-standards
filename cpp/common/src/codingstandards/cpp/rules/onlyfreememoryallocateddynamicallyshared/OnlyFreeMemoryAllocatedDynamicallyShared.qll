/**
 * Provides a library which includes a `problems` predicate for reporting memory
 * that is not allocated dynamically being subsequently freed via a call to `free`.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Allocations
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.dataflow.DataFlow2

/**
 * A pointer to potentially dynamically allocated memory
 */
class AllocExprSource extends DataFlow::Node {
  AllocExprSource() {
    allocExprOrIndirect(this.asExpr(), _)
    or
    // additionally include calls to library functions or output parameters
    // to heuristically reduce false-positives from library functions that
    // might provide pointers to dynamically allocated memory
    exists(FunctionCall fc |
      not exists(fc.getTarget().getBlock()) and
      (
        this.asExpr() = fc or
        this.asDefiningArgument() = fc.getAnArgument()
      )
    )
  }
}

/**
 * An argument to a call to `free` or `realloc`.
 */
class FreeExprSink extends DataFlow::Node {
  FreeExprSink() { freeExpr(_, this.asExpr(), "free") }
}

/**
 * A data-flow configuration that tracks flow from an `AllocExprSource` to
 * the value assigned to a variable.
 */
class AllocExprSourceToAssignedValueConfig extends DataFlow2::Configuration {
  AllocExprSourceToAssignedValueConfig() { this = "AllocExprSourceToAssignedValueConfig" }

  override predicate isSource(DataFlow::Node source) { source instanceof AllocExprSource }

  override predicate isSink(DataFlow::Node sink) {
    sink.asExpr() = any(Variable v).getAnAssignedValue()
  }
}

/**
 * An assignment of a value that is not a dynamically allocated pointer to a variable.
 */
class NonDynamicallyAllocatedVariableAssignment extends DataFlow::Node {
  NonDynamicallyAllocatedVariableAssignment() {
    exists(Variable v |
      this.asExpr() = v.getAnAssignedValue() and
      not this.asExpr() instanceof NullValue and
      not any(AllocExprSourceToAssignedValueConfig cfg).hasFlowTo(this)
    )
  }
}

/**
 * A data-flow configuration that tracks flow from an `AllocExprSource` to a `FreeExprSink`.
 */
class DynamicMemoryAllocationToFreeConfig extends DataFlow::Configuration {
  DynamicMemoryAllocationToFreeConfig() { this = "DynamicMemoryAllocationToFreeConfig" }

  override predicate isSource(DataFlow::Node source) { source instanceof AllocExprSource }

  override predicate isSink(DataFlow::Node sink) { sink instanceof FreeExprSink }
}

/**
 * A data-flow configuration that tracks flow from a
 * `NonDynamicallyAllocatedVariableAssignment` to a `FreeExprSink`.
 */
class NonDynamicPointerToFreeConfig extends DataFlow::Configuration {
  NonDynamicPointerToFreeConfig() { this = "NonDynamicPointerToFreeConfig" }

  override predicate isSource(DataFlow::Node source) {
    source instanceof NonDynamicallyAllocatedVariableAssignment
  }

  override predicate isSink(DataFlow::Node sink) { sink instanceof FreeExprSink }

  override predicate isBarrierOut(DataFlow::Node node) {
    // the default interprocedural data-flow model flows through any field or array assignment
    // expressionsto the qualifier (array base, pointer dereferenced, or qualifier) instead of the
    // individual element or field that the assignment modifies. this default behaviour causes
    // false positives for future frees of the object base, so we remove the edges
    // between those assignments from the graph with `isBarrierOut`.
    exists(AssignExpr a |
      node.asExpr() = a.getRValue() and
      (
        a.getLValue() instanceof ArrayExpr or
        a.getLValue() instanceof PointerDereferenceExpr or
        a.getLValue() instanceof FieldAccess
      )
    )
  }
}

abstract class OnlyFreeMemoryAllocatedDynamicallySharedSharedQuery extends Query { }

Query getQuery() { result instanceof OnlyFreeMemoryAllocatedDynamicallySharedSharedQuery }

query predicate problems(
  FreeExprSink free, string message, DataFlow::Node source, string sourceDescription
) {
  not isExcluded(free.asExpr(), getQuery()) and
  (
    not any(DynamicMemoryAllocationToFreeConfig cfg).hasFlowTo(free) and
    not any(NonDynamicPointerToFreeConfig cfg).hasFlowTo(free) and
    message = "Free expression frees non-dynamically allocated memory." and
    source = free and
    sourceDescription = ""
    or
    any(NonDynamicPointerToFreeConfig cfg).hasFlow(source, free) and
    message = "Free expression frees $@ which was not dynamically allocated." and
    sourceDescription = "memory"
  )
}

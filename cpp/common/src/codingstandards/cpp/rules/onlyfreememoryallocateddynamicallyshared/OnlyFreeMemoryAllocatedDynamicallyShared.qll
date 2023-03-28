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
import DataFlow::PathGraph

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
 * An `Expr` that is an `AddressOfExpr` of a `Variable`.
 *
 * `Field`s of `PointerType` are not included in order to reduce false-positives,
 * as the data-flow library sometimes equates pointers to their underlying data.
 */
class AddressOfExprSourceNode extends Expr {
  AddressOfExprSourceNode() {
    exists(VariableAccess va |
      this.(AddressOfExpr).getOperand() = va and
      (
        va.getTarget() instanceof StackVariable or
        va.getTarget() instanceof GlobalVariable or
        // allow address-of field, but only if that field is not a pointer type,
        // as there may be nested allocations assigned to fields of pointer types.
        va.(FieldAccess).getTarget().getUnderlyingType() instanceof ArithmeticType
      )
      or
      this = va and
      exists(GlobalVariable gv |
        gv = va.getTarget() and
        (
          gv.getUnderlyingType() instanceof ArithmeticType or
          not exists(gv.getAnAssignedValue()) or
          exists(AddressOfExprSourceNode other |
            DataFlow::localExprFlow(other, gv.getAnAssignedValue())
          )
        )
      )
    ) and
    // exclude alloc(&allocated_ptr) cases
    not any(DynamicMemoryAllocationToAddressOfDefiningArgConfig cfg)
        .hasFlowTo(DataFlow::definitionByReferenceNodeFromArgument(this))
  }
}

/**
 * A data-flow configuration that tracks flow from an `AllocExprSource` to a `FreeExprSink`.
 */
class DynamicMemoryAllocationToAddressOfDefiningArgConfig extends DataFlow2::Configuration {
  DynamicMemoryAllocationToAddressOfDefiningArgConfig() {
    this = "DynamicMemoryAllocationToAddressOfDefiningArgConfig"
  }

  override predicate isSource(DataFlow::Node source) { source instanceof AllocExprSource }

  override predicate isSink(DataFlow::Node sink) {
    sink.asDefiningArgument() instanceof AddressOfExpr
  }
}

/**
 * A data-flow configuration that tracks flow from a
 * `NonDynamicallyAllocatedVariableAssignment` to a `FreeExprSink`.
 */
class NonDynamicPointerToFreeConfig extends DataFlow::Configuration {
  NonDynamicPointerToFreeConfig() { this = "NonDynamicPointerToFreeConfig" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof AddressOfExprSourceNode
  }

  override predicate isSink(DataFlow::Node sink) { sink instanceof FreeExprSink }

  override predicate isBarrierOut(DataFlow::Node node) {
    // the default interprocedural data-flow model flows through any field or array assignment
    // expressions to the qualifier (array base, pointer dereferenced, or qualifier) instead of the
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

  override predicate isBarrierIn(DataFlow::Node node) {
    // only the last source expression is relevant
    isSource(node)
  }
}

abstract class OnlyFreeMemoryAllocatedDynamicallySharedSharedQuery extends Query { }

Query getQuery() { result instanceof OnlyFreeMemoryAllocatedDynamicallySharedSharedQuery }

query predicate problems(
  DataFlow::PathNode element, DataFlow::PathNode source, DataFlow::PathNode sink, string message
) {
  not isExcluded(element.getNode().asExpr(), getQuery()) and
  element = sink and
  any(NonDynamicPointerToFreeConfig cfg).hasFlowPath(source, sink) and
  message = "Free expression frees memory which was not dynamically allocated."
}

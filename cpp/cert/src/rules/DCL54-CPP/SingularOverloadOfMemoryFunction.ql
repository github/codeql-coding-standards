/**
 * @id cpp/cert/singular-overload-of-memory-function
 * @name DCL54-CPP: Overload allocation and deallocation functions as a pair in the same scope
 * @description Allocation and deallocation functions can be overloaded and not providing an
 *              overload of a corresponding dynamic storage function can result in improper
 *              deallocation of dynamically allocated memory leading to undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl54-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Scope

abstract class AllocationOrDeallocationFunction extends Function {
  abstract predicate isArrayForm();

  abstract predicate requiresPair();

  abstract predicate isAllocation();

  abstract predicate isDeallocation();
}

class NewOperator extends AllocationOrDeallocationFunction {
  NewOperator() { this.hasName(["operator new", "operator new[]"]) }

  predicate isNonAllocatingPlacementOperator() {
    this.getNumberOfParameters() = 2 and this.getParameter(1).getType() instanceof VoidPointerType
  }

  override predicate requiresPair() { not isNonAllocatingPlacementOperator() }

  override predicate isArrayForm() { this.hasName("operator new[]") }

  override predicate isAllocation() { any() }

  override predicate isDeallocation() { none() }
}

class DeleteOperator extends AllocationOrDeallocationFunction {
  DeleteOperator() { this.hasName(["operator delete", "operator delete[]"]) }

  override predicate isArrayForm() { this.hasName("operator delete[]") }

  override predicate isAllocation() { none() }

  override predicate isDeallocation() { any() }

  override predicate requiresPair() { any() }
}

from
  AllocationOrDeallocationFunction allocOrDealloc, Scope allocOrDeallocScope, string overloaded,
  string missing
where
  not isExcluded(allocOrDealloc, ScopePackage::singularOverloadOfMemoryFunctionQuery()) and
  allocOrDealloc = allocOrDeallocScope.getADeclaration() and
  allocOrDealloc.requiresPair() and
  not exists(AllocationOrDeallocationFunction correspondingAllocOrDealloc |
    allocOrDeallocScope.getADeclaration() = correspondingAllocOrDealloc and
    (
      allocOrDealloc.isArrayForm() and correspondingAllocOrDealloc.isArrayForm()
      or
      not (allocOrDealloc.isArrayForm() or correspondingAllocOrDealloc.isArrayForm())
    ) and
    (
      allocOrDealloc.isAllocation() and correspondingAllocOrDealloc.isDeallocation()
      or
      allocOrDealloc.isDeallocation() and correspondingAllocOrDealloc.isAllocation()
    )
  ) and
  (
    allocOrDealloc.isAllocation() and overloaded = "allocation" and missing = "deallocation"
    or
    allocOrDealloc.isDeallocation() and overloaded = "deallocation" and missing = "allocation"
  )
select allocOrDealloc,
  "Overloaded $@ function misses required corresponding " + missing +
    " function overload in the same $@.", allocOrDealloc, overloaded, allocOrDeallocScope, "scope"

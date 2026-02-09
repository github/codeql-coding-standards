/**
 * @id cpp/cert/detect-and-handle-memory-allocation-errors
 * @name MEM52-CPP: Detect and handle memory allocation errors
 * @description Ignoring memory allocation failures can lead to use of invalid pointers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/mem52-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.exceptions.ExceptionSpecifications

/**
 * A nothrow non placement new or new array expression.
 */
class NoThrowNewOrNewArrayExpr extends NewOrNewArrayExpr {
  NoThrowNewOrNewArrayExpr() {
    // Call to a "noexcept(true)" allocation function
    isNoExceptTrue(getAllocatorCall().getTarget()) and
    // Do not report placement new, as no validation checks are required in that case
    not exists(getPlacementPointer())
  }
}

/**
 * An expression that performs a nothrow allocation and has not yet checked the return value to
 * determine whether it is a nullptr.
 */
class NoThrowAllocExpr extends Expr {
  NoThrowNewOrNewArrayExpr underlyingAlloc;

  NoThrowAllocExpr() {
    underlyingAlloc = this
    or
    exists(NoThrowAllocExprWrapperFunction f |
      this.(FunctionCall).getTarget() = f and underlyingAlloc = f.getUnderlyingAlloc()
    )
  }

  /** Gets the underlying nothrow allocation ultimately called. */
  NoThrowNewOrNewArrayExpr getUnderlyingAlloc() { result = underlyingAlloc }
}

/**
 * A function wrapping a nothrow allocation which returns the pointer and has not checked to
 * determine whether it is a nullptr.
 */
class NoThrowAllocExprWrapperFunction extends Function {
  NoThrowAllocExpr n;

  NoThrowAllocExprWrapperFunction() {
    n.getEnclosingFunction() = this and
    DataFlow::localExprFlow(n, any(ReturnStmt rs).getExpr()) and
    // Not checked in this wrapper function
    not exists(GuardCondition gc | DataFlow::localExprFlow(n, gc.getAChild*()))
  }

  /** Gets the underlying nothrow allocation ultimately being wrapped. */
  NoThrowNewOrNewArrayExpr getUnderlyingAlloc() { result = n.getUnderlyingAlloc() }
}

class NotWrappedNoThrowAllocExpr extends NoThrowAllocExpr {
  NotWrappedNoThrowAllocExpr() {
    not getEnclosingFunction() instanceof NoThrowAllocExprWrapperFunction
  }
}

/**
 * A data flow configuration for finding nothrow allocation calls which are checked in some kind of guard.
 */
module NoThrowNewErrorCheckConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof NotWrappedNoThrowAllocExpr
  }

  predicate isSink(DataFlow::Node sink) { sink.asExpr() = any(GuardCondition gc).getAChild*() }
}

module NoThrowNewErrorCheckFlow = DataFlow::Global<NoThrowNewErrorCheckConfig>;

from NotWrappedNoThrowAllocExpr ae
where
  not isExcluded(ae, AllocationsPackage::detectAndHandleMemoryAllocationErrorsQuery()) and
  not NoThrowNewErrorCheckFlow::flow(DataFlow::exprNode(ae), _)
select ae,
  "nothrow new allocation of $@ returns here without a subsequent check to see whether the pointer is valid.",
  ae.getUnderlyingAlloc() as underlying, underlying.getType().getName()

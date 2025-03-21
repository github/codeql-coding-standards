import codingstandards.cpp.cert
import codingstandards.cpp.Conversion
import codingstandards.cpp.types.TrivialType
import ManuallyManagedLifetime
import semmle.code.cpp.controlflow.Dominance
import semmle.code.cpp.dataflow.TaintTracking

/**
 * A taint-tracking configuration from allocation expressions to casts to a specific pointer type.
 *
 * We use a taint-tracking configuration because we also want to track sub-sections
 */
module AllocToStaticCastConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(AllocationExpr ae |
      ae.getType().getUnspecifiedType() instanceof VoidPointerType and
      source.asExpr() = ae
    )
  }

  predicate isBarrier(DataFlow::Node sanitizer) {
    // Ignore realloc, as that memory may already be partially constructed
    sanitizer.asExpr().(FunctionCall).getTarget().getName().toLowerCase().matches("%realloc%")
  }

  predicate isSink(DataFlow::Node sink) {
    exists(StaticOrCStyleCast sc, Class nonTrivialClass |
      sc.getExpr() = sink.asExpr() and
      nonTrivialClass = sc.getType().getUnspecifiedType().(PointerType).getBaseType() and
      not isTrivialType(nonTrivialClass)
    )
  }
}

module AllocToStaticCastFlow = TaintTracking::Global<AllocToStaticCastConfig>;

/**
 * A cast of some existing memory, where we believe the resulting pointer has not been properly
 * constructed.
 */
class CastWithoutConstruction extends StaticOrCStyleCast {
  CastWithoutConstruction() { AllocToStaticCastFlow::flowToExpr(getExpr()) }
}

/*
 * For deallocation we have two cases to consider:
 *  - If the constructor was never called, we should track from the cast to the free when it is not via the constructor.
 *  - If the constructor was called using placement new, we should confirm the destructor is manually
 *    called at least somewhere in the program (ideally before the memory is freed)
 *
 * We currently support the first case, but not the second.
 */

/**
 * A direct or indirect call to a destructor.
 */
class DirectOrIndirectDestructorCall extends Expr {
  Expr destructedObject;

  DirectOrIndirectDestructorCall() {
    destructedObject = this.(DestructorCall).getQualifier()
    or
    destructedObject = this.(VacuousDestructorCall).getQualifier()
    or
    // Calls a wrapper around a desctructor call
    exists(FunctionCall fc, Function target, int i |
      this = fc and
      fc.getTarget() = target and
      destructedObject = fc.getArgument(i) and
      DataFlow::localFlow(DataFlow::parameterNode(target.getParameter(i)),
        DataFlow::exprNode(any(DirectOrIndirectDestructorCall adc).getDestructedArgument()))
    )
  }

  /** Gets the argument whose destructor will be called. */
  Expr getDestructedArgument() { result = destructedObject }
}

/** A non-local variable. */
private class NonLocalVariable extends Variable {
  NonLocalVariable() { not this instanceof LocalScopeVariable }
}

/**
 * A deallocation call that does not call the destructor.
 */
class NonDestructingDeallocationCall extends Expr {
  NonDestructingDeallocationCall() {
    this instanceof DeallocationExpr and
    not this instanceof DeleteExpr and
    not this instanceof DeleteArrayExpr
  }

  Expr getFreedExpr() { result = this.(DeallocationExpr).getFreedExpr() }
}

/**
 * A data flow configuration from a `CastWithoutConstruction` to a free call on the memory without
 * an intervening destructor invocation.
 */
module FreeWithoutDestructorConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr() = any(CastWithoutConstruction c).getExpr()
  }

  predicate isSink(DataFlow::Node sink) {
    sink.asExpr() = any(NonDestructingDeallocationCall de).getFreedExpr()
  }

  predicate isBarrier(DataFlow::Node barrier) {
    // Consider any expression which later has a destructor called upon it to be safe.
    exists(DirectOrIndirectDestructorCall dc |
      DataFlow::localFlow(barrier, DataFlow::exprNode(dc.getDestructedArgument()))
      or
      // Field and global flow may not be captured with localFlow
      exists(NonLocalVariable nonLocal, VariableAccess otherAccess |
        dc.getDestructedArgument() = nonLocal.getAnAccess() and
        otherAccess.getEnclosingFunction() = dc.getEnclosingFunction() and
        otherAccess.getTarget() = nonLocal and
        barrier.asExpr() = otherAccess
      )
    )
  }

  predicate isAdditionalFlowStep(DataFlow::Node stepFrom, DataFlow::Node stepTo) {
    stepTo.asExpr().(StaticOrCStyleCast).getExpr() = stepFrom.asExpr()
  }
}

module FreeWithoutDestructorFlow = DataFlow::Global<FreeWithoutDestructorConfig>;

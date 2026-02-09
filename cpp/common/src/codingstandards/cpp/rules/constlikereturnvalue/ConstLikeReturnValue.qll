/**
 * Provides a library with a `problems` predicate for the following issue:
 * The pointers returned by the Standard Library functions localeconv, getenv,
 * setlocale or, strerror shall only be used as if they have pointer to
 * const-qualified type.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow
import DFFlow::PathGraph

abstract class ConstLikeReturnValueSharedQuery extends Query { }

Query getQuery() { result instanceof ConstLikeReturnValueSharedQuery }

/**
 * Call to functions that return pointers to environment objects that should not be modified.
 */
class NotModifiableCall extends FunctionCall {
  NotModifiableCall() {
    this.getTarget().hasGlobalName(["getenv", "setlocale", "localeconv", "asctime", "strerror"])
  }
}

/**
 * An expression that modifies an object.
 */
class ObjectWrite extends Expr {
  ObjectWrite() {
    // the pointed object is reassigned
    exists(Expr e |
      e = [any(AssignExpr ae).getLValue(), any(CrementOperation co).getOperand()] and
      (
        this = e.(PointerDereferenceExpr).getOperand()
        or
        this = e.(PointerFieldAccess).getQualifier()
      )
    )
  }
}

/**
 * DF configuration for flows from a `NotModifiableCall` to a object modifications.
 */
module DFConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source.asExpr() instanceof NotModifiableCall }

  predicate isSink(DataFlow::Node sink) { sink.asExpr() instanceof ObjectWrite }
}

module DFFlow = DataFlow::Global<DFConfig>;

query predicate problems(Element e, DFFlow::PathNode source, DFFlow::PathNode sink, string message) {
  not isExcluded(e, getQuery()) and
  // the modified object comes from a call to one of the ENV functions
  DFFlow::flowPath(source, sink) and
  e = sink.getNode().asExpr() and
  message =
    "The object returned by the function " +
      source.getNode().asExpr().(FunctionCall).getTarget().getName() + " should not be modified."
}

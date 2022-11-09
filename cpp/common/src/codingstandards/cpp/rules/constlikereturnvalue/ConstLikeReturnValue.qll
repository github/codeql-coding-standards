/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

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
class DFConf extends DataFlow::Configuration {
  DFConf() { this = "DFConf" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof NotModifiableCall
  }

  override predicate isSink(DataFlow::Node sink) { sink.asExpr() instanceof ObjectWrite }
}

query predicate problems(
  Element e, DataFlow::PathNode source, DataFlow::PathNode sink, string message
) {
  not isExcluded(e, getQuery()) and
  // the modified object comes from a call to one of the ENV functions
  any(DFConf d).hasFlowPath(source, sink) and
  e = sink.getNode().asExpr() and
  message =
    "The object returned by the function " +
      source.getNode().asExpr().(FunctionCall).getTarget().getName() + " should not be modified."
}

/**
 * @id c/cert/do-not-modify-the-return-value-of-certain-functions
 * @name ENV30-C: Do not modify the return value of certain functions
 * @description Return value of getenv and similar functions cannot be modified.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/env30-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

/*
 * Call to functions that return pointers to environment objects that should not be modified.
 */

class NotModifiableCall extends FunctionCall {
  NotModifiableCall() {
    this.getTarget()
        .hasGlobalOrStdName(["getenv", "setlocale", "localeconv", "asctime", "strerror"])
  }
}

/*
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

from DataFlow::PathNode source, DataFlow::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    Contracts1Package::doNotModifyTheReturnValueOfCertainFunctionsQuery()) and
  // the modified object comes from a call to one of the ENV functions
  any(DFConf d).hasFlowPath(source, sink)
select sink.getNode(), source, sink,
  "The object returned by the function " +
    source.getNode().asExpr().(FunctionCall).getTarget().getName() + " should no be modified."

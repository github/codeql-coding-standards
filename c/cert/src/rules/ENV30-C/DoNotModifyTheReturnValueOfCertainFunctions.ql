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
 * Returns an expression that modifies an object pointed by the return value of a call
 * to one of the `NotModifiableCall` functions.
 */

Expr objectModified(NotModifiableCall c) {
  // the pointed object is reassigned
  exists(AssignExpr ae |
    result =
      [ae.getLValue().(PointerDereferenceExpr), ae.getLValue().(PointerFieldAccess).getQualifier*()] and
    //exclude overwrite from the same function
    not ae.getRValue().(FunctionCall).getTarget().getName() = c.getTarget().getName() and
    //exclude overwriting of localeconv returned object with setlocale() with categories LC_ALL (0) LC_MONETARY (3) LC_NUMERIC (4)
    not (
      c.getTarget().getName() = "localeconv" and
      ae.getRValue().(FunctionCall).getTarget().getName() = "setlocale" and
      ae.getRValue().(FunctionCall).getArgument(0).getValue() = ["0", "3", "4"]
    )
  )
}

/**
 * DF configuration for flows from a `NotModifiableCall` to a object modifications.
 */
class DFConf extends DataFlow::Configuration {
  DFConf() { this = "DFConf" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof NotModifiableCall
  }

  override predicate isSink(DataFlow::Node sink) { any() }

  // Flow through pointer dereference expressions
  override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(PointerDereferenceExpr de |
      de.getOperand() = node1.asExpr() and
      de = node2.asExpr()
    )
  }
}

from DataFlow::PathNode source, DataFlow::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    Contracts1Package::doNotModifyTheReturnValueOfCertainFunctionsQuery()) and
  sink != source and
  sink.getNode().asExpr() = objectModified(source.getNode().asExpr()) and
  // the modified object comes from a call to one of the ENV functions
  any(DFConf d).hasFlowPath(source, sink)
select sink.getNode(), source, sink,
  "The object returned by the function " +
    source.getNode().asExpr().(FunctionCall).getTarget().getName() + " should no be modified."

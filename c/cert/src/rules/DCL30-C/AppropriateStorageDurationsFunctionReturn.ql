/**
 * @id c/cert/declare-objects-with-appropriate-storage-durations
 * @name DCL30-C: Declare objects with appropriate storage durations
 * @description When storage durations are not compatible between assigned pointers it can lead to
 *              referring to objects outside of their lifetime, which is undefined behaviour.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/dcl30-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.FunctionParameter
import semmle.code.cpp.dataflow.DataFlow

class Source extends StackVariable {
  Source() { not this instanceof FunctionParameter }
}

abstract class Sink extends DataFlow::Node { }

class FunctionSink extends Sink {
  FunctionSink() {
    //output parameter
    exists(FunctionParameter f |
      f.getAnAccess() = this.(DataFlow::PostUpdateNode).getPreUpdateNode().asExpr() and
      f.getUnderlyingType() instanceof PointerType
    )
    or
    //function returns pointer
    exists(Function f, ReturnStmt r |
      f.getType() instanceof PointerType and
      r.getEnclosingFunction() = f and
      r.getExpr() = this.asExpr()
    )
  }
}

from DataFlow::Node src, DataFlow::Node sink
where
  not isExcluded(sink.asExpr(),
    Declarations8Package::appropriateStorageDurationsFunctionReturnQuery()) and
  exists(Source s | src.asExpr() = s.getAnAccess()) and
  sink instanceof Sink and
  DataFlow::localFlow(src, sink)
select sink, "$@ with automatic storage may be accessible outside of its lifetime.", src,
  src.toString()

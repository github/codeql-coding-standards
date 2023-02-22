/**
 * @id c/cert/appropriate-storage-durations-function-return
 * @name DCL30-C: Declare objects with appropriate storage durations
 * @description When pointers to local variables are returned by a function it can lead to referring
 *              to objects outside of their lifetime, which is undefined behaviour.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/dcl30-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow

class Source extends StackVariable {
  Source() { not this instanceof Parameter }
}

class Sink extends DataFlow::Node {
  Sink() {
    //output parameter
    exists(Parameter f |
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

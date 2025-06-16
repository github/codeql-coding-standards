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
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Objects
import semmle.code.cpp.dataflow.DataFlow

class Source extends Expr {
  ObjectIdentity rootObject;

  Source() {
    rootObject.getStorageDuration().isAutomatic() and
    this = rootObject.getASubobjectAddressExpr()
  }
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
  exists(Source s | src.asExpr() = s) and
  sink instanceof Sink and
  DataFlow::localFlow(src, sink)
select sink, "$@ with automatic storage may be accessible outside of its lifetime.", src,
  src.toString()

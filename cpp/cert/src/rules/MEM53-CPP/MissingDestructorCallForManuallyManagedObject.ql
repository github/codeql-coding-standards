/**
 * @id cpp/cert/missing-destructor-call-for-manually-managed-object
 * @name MEM53-CPP: Explicitly destruct objects when manually managing object lifetime
 * @description Objects with manually managed lifetimes must be explicitly destructed.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/mem53-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import ManuallyManagedLifetime
import semmle.code.cpp.dataflow.DataFlow2
import DataFlow2::PathGraph

from FreeWithoutDestructorConfig dc, DataFlow2::PathNode source, DataFlow2::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    AllocationsPackage::missingDestructorCallForManuallyManagedObjectQuery()) and
  dc.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Memory freed without an appropriate destructor called."

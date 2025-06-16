/**
 * @id cpp/cert/missing-destructor-call-for-manually-managed-object
 * @name MEM53-CPP: Explicitly destruct objects when manually managing object lifetime
 * @description Objects with manually managed lifetimes must be explicitly destructed.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/mem53-cpp
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
import ManuallyManagedLifetime
import semmle.code.cpp.dataflow.DataFlow
import FreeWithoutDestructorFlow::PathGraph

from FreeWithoutDestructorFlow::PathNode source, FreeWithoutDestructorFlow::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    AllocationsPackage::missingDestructorCallForManuallyManagedObjectQuery()) and
  FreeWithoutDestructorFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Memory freed without an appropriate destructor called."

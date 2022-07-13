/**
 * @id cpp/cert/missing-constructor-call-for-manually-managed-object
 * @name MEM53-CPP: Explicitly construct objects when manually managing object lifetime
 * @description Objects with manually managed lifetimes must be explicitly constructed.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/mem53-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.TrivialType
import ManuallyManagedLifetime
import semmle.code.cpp.dataflow.TaintTracking
import DataFlow::PathGraph

/*
 * Find flow from a manual allocation returning void* to a static_cast (or c-style cast)
 * to a specific type.
 */

from AllocToStaticCastConfig config, DataFlow::PathNode source, DataFlow::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    AllocationsPackage::missingConstructorCallForManuallyManagedObjectQuery()) and
  config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Allocation to cast without constructor call"

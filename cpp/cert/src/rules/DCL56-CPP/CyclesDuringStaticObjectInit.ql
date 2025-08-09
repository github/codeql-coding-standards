/**
 * @id cpp/cert/cycles-during-static-object-init
 * @name DCL56-CPP: Avoid cycles during initialization of static objects
 * @description Cycles during initialization of static objects can lead to undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/dcl56-cpp
 *       correctness
 *       maintainability
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.StaticInitialization
import StaticInitializationGraph

/**
 * Holds if `v` is a `StaticStorageDurationVariable` whose initializer is recursive.
 */
predicate hasRecursiveInitializer(StaticStorageDurationVariable v) {
  // Not an excluded static variable
  not isExcluded(v, InitializationPackage::cyclesDuringStaticObjectInitQuery()) and
  exists(InitializerNode i |
    i.getInitializer() = v.getInitializer() and
    // The initializer is recursive in the static initialization graph
    step+(i, i)
  )
}

/**
 * An `edges` predicate to support the `path-problem` query. Reports edges between
 * `StaticInitializationGraph` nodes which are relevant to `StaticStorageDurationVariable`s with
 * initializers that are recursive.
 */
query predicate edges(Node n1, Node n2) {
  exists(StaticStorageDurationVariable v | hasRecursiveInitializer(v) |
    // n1 and n2 are reachable from the initializer
    n1 = getAReachableNode(v) and
    n2 = getAReachableNode(v) and
    // And have a step between them
    step(n1, n2)
  )
}

from StaticStorageDurationVariable v, Node startNode, InitializerNode initializerNode
where
  hasRecursiveInitializer(v) and
  initializerNode.getInitializer() = v.getInitializer() and
  step(initializerNode, startNode)
select v, startNode, initializerNode,
  "Initialization of variable " + v + " calls itself recursively."

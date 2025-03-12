/**
 * Provides a library which includes a `problems` predicate for reporting resources
 * that are not released before an exception is thrown
 */

import cpp
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Customizations
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.ExceptionSafety
import codingstandards.cpp.resources.ResourceManagement
import codingstandards.cpp.resources.ResourceLeakAnalysis

abstract class ExceptionSafetyValidStateSharedQuery extends Query { }

Query getQuery() { result instanceof ExceptionSafetyValidStateSharedQuery }

/**
 * `UncaughtThrowExpr` models a `throw` expression that is not handled
 */
class UncaughtThrowExpr extends ThrowExpr {
  UncaughtThrowExpr() { getASuccessor() = getEnclosingFunction() }
}

module ThrowLeakConfig implements ResourceLeakConfigSig {
  predicate isAllocate(ControlFlowNode node, DataFlow::Node resource) {
    ResourceLeakConfig::isAllocate(node, resource)
  }

  predicate isFree(ControlFlowNode node, DataFlow::Node resource) {
    ResourceLeakConfig::isFree(node, resource)
  }

  ControlFlowNode outOfScope(ControlFlowNode allocPoint) {
    result.(UncaughtThrowExpr).getEnclosingFunction() = allocPoint.(Expr).getEnclosingFunction()
  }

  DataFlow::Node getAnAlias(DataFlow::Node node) { DataFlow::localFlow(node, result) }
}

query predicate problems(UncaughtThrowExpr te, string message, Element e, string eDescription) {
  not isExcluded(te, getQuery()) and
  te = ResourceLeak<ThrowLeakConfig>::getALeak(e) and
  message = "The $@ is not released explicitly before throwing an exception." and
  eDescription = "allocated resource"
}

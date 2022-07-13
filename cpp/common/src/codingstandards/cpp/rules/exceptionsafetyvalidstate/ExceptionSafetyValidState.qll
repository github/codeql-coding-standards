/**
 * Provides a library which includes a `problems` predicate for reporting resources
 * that are not released before an exception is thrown
 */

import cpp
import semmle.code.cpp.controlflow.SubBasicBlocks
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Customizations
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.ExceptionSafety
import codingstandards.cpp.resources.ResourceManagement

abstract class ExceptionSafetyValidStateSharedQuery extends Query { }

Query getQuery() { result instanceof ExceptionSafetyValidStateSharedQuery }

/**
 * Ensures that `UncaughtThrowExpr` and `Expr` appear at the start of a `SubBasicBlock`.
 */
class SafetyValidStateSubBasicBlock extends SubBasicBlockCutNode {
  SafetyValidStateSubBasicBlock() {
    this instanceof ResourceAcquisitionExpr or
    this = any(ResourceAcquisitionExpr rae).getReleaseExpr() or
    this instanceof UncaughtThrowExpr
  }
}

/**
 * Execution continues from an allocation expression
 * without releasing the resource
 */
SubBasicBlock followsInitialized(ResourceAcquisitionExpr src) {
  result = src
  or
  exists(SubBasicBlock mid |
    mid = followsInitialized(src) and
    result = mid.getASuccessor() and
    //stop recursion on resource release
    not result = src.getReleaseExpr()
  )
}

/**
 * `UncaughtThrowExpr` models a `throw` expression that is not handled
 */
class UncaughtThrowExpr extends ThrowExpr {
  UncaughtThrowExpr() { getASuccessor() = getEnclosingFunction() }
}

query predicate problems(
  UncaughtThrowExpr te, string message, ResourceAcquisitionExpr e, string eDescription
) {
  not isExcluded(te, getQuery()) and
  exists(SubBasicBlock sbb |
    sbb.getANode() = e and
    te = followsInitialized(sbb)
  ) and
  message = "The $@ is not released explicitly before throwing an exception." and
  eDescription = "allocated resource"
}

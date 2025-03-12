/**
 * Provides a library which includes a `problems` predicate for reporting instances of
 * assignment of stack addresses to other variables with a wider scope.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.StackAddress

abstract class DoNotCopyAddressOfAutoStorageObjectToOtherObjectSharedQuery extends Query { }

/*
 * This is a variant of the `cpp/stack-address-escape` query, provided in the CodeQL C++ default
 * query set, which enforces the stricter version of the rule required by MISRA. In particular,
 * MISRA requires that stack addresses are never assigned to other stack variables with a wider
 * scope, even if the address never leaks from the function itself.
 */

/**
 * Find assignments where the rhs might be a stack pointer and the lhs is
 * not a stack variable. Such assignments might allow a stack address to
 * escape.
 */
predicate stackAddressEscapes(AssignExpr assignExpr, Expr source, boolean isLocal) {
  stackPointerFlowsToUse(assignExpr.getRValue(), _, source, isLocal) and
  (
    // Not assigned to a StackVariable
    not stackReferenceFlowsToUse(assignExpr.getLValue(), _, _, _)
    or
    // Assigned to a StackVariable with wider scope
    exists(StackVariable rvalueVar, StackVariable lvalueVar, Expr lvalueSource |
      // Restrict to local variables
      stackReferenceFlowsToUse(assignExpr.getLValue(), _, lvalueSource, true) and
      lvalueSource = lvalueVar.getAnAccess() and
      source = rvalueVar.getAnAccess() and
      lvalueVar.getParentScope() = rvalueVar.getParentScope().getParentScope+()
    )
  )
}

Query getQuery() { result instanceof DoNotCopyAddressOfAutoStorageObjectToOtherObjectSharedQuery }

query predicate problems(Expr use, string message, Expr source, string srcStr) {
  not isExcluded(use, getQuery()) and
  exists(boolean isLocal |
    stackAddressEscapes(use, source, isLocal) and
    if isLocal = true
    then (
      message = "A stack address ($@) may be assigned to a non-local variable." and
      srcStr = "source"
    ) else (
      message = "A stack address which arrived via a $@ may be assigned to a non-local variable." and
      srcStr = "parameter"
    )
  )
}

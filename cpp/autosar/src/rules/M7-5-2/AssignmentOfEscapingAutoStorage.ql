/**
 * @id cpp/autosar/assignment-of-escaping-auto-storage
 * @name M7-5-2: Do not assign the address of an object with automatic storage to an object that may persist after it's lifetime
 * @description The address of an object with automatic storage shall not be assigned to another
 *              object that may persist after the first object has ceased to exist.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m7-5-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.StackAddress

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

from Expr use, Expr source, boolean isLocal, string msg, string srcStr
where
  not isExcluded(use, FreedPackage::assignmentOfEscapingAutoStorageQuery()) and
  stackAddressEscapes(use, source, isLocal) and
  if isLocal = true
  then (
    msg = "A stack address ($@) may be assigned to a non-local variable." and
    srcStr = "source"
  ) else (
    msg = "A stack address which arrived via a $@ may be assigned to a non-local variable." and
    srcStr = "parameter"
  )
select use, msg, source, srcStr

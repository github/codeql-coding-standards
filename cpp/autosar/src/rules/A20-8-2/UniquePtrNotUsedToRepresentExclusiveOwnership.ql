/**
 * @id cpp/autosar/unique-ptr-not-used-to-represent-exclusive-ownership
 * @name A20-8-2: A std::unique_ptr shall be used to represent exclusive ownership
 * @description Sharing ownership of a raw pointer, including the underlying object of an
 *              std::unique_ptr, risks resource leakage and complicated scope.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a20-8-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SmartPointers

from Variable var, AllocationExpr ae, Declaration decl
where
  not isExcluded(var, SmartPointers1Package::uniquePtrNotUsedToRepresentExclusiveOwnershipQuery()) and
  var.getType() instanceof PointerType and
  not var.isFromUninstantiatedTemplate(_) and
  ae = var.getAnAssignedValue() and
  (
    // local scope variables with the result of an allocation expression (e.g. new and malloc)
    var instanceof LocalScopeVariable and
    not allocationFlowsToOwnershipSharingExpr(ae) and
    decl = var.(LocalScopeVariable).getFunction()
    or
    // non-static member variables with the result of an allocation expression assigned in a Constructor
    var instanceof Field and
    ae.getEnclosingFunction() instanceof Constructor and
    not fieldFlowsToOwnershipSharingExpr(var) and
    decl = var.getDeclaringType()
  )
select var, "Raw pointer $@ is exclusively owned by $@ but is not declared as an std::unique_ptr.",
  var, var.getName(), decl, decl.getName()

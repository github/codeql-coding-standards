/**
 * @id cpp/autosar/shared-ptr-not-used-to-represent-shared-ownership
 * @name A20-8-3: A std::shared_ptr shall be used to represent shared ownership
 * @description An std::shared_ptr should be used to ensure that underlying objects remain valid if
 *              a different std::shared_ptr instance is destroyed.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a20-8-3
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
    allocationFlowsToOwnershipSharingExpr(ae) and
    decl = var.(LocalScopeVariable).getFunction()
    or
    // non-static member variables with the result of an allocation expression assigned in a Constructor
    var instanceof Field and
    ae.getEnclosingFunction() instanceof Constructor and
    fieldFlowsToOwnershipSharingExpr(var) and
    decl = var.getDeclaringType()
  )
select var, "Raw pointer $@ ownership is shared by $@ but is not declared as an std::shared_ptr.",
  var, var.getName(), decl, decl.getName()

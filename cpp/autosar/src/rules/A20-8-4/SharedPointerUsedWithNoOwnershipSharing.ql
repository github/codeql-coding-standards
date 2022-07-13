/**
 * @id cpp/autosar/shared-pointer-used-with-no-ownership-sharing
 * @name A20-8-4: A std::unique_ptr shall be used over std::shared_ptr if ownership sharing is not required
 * @description An std::unique_ptr provides sufficient functionality and demonstrates intended usage
 *              without the overhead of std::shared_ptr if shared ownership is not required.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a20-8-4
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SmartPointers
import semmle.code.cpp.dataflow.DataFlow

/*
 * Finds `std::shared_ptr` local variables which are not copy or move initialized, and are not used in
 * a context which suggests the variable is being shared with another potential owner.
 */

private class AutosarSharedPointerLocalScopeVariable extends LocalScopeVariable {
  AutosarSharedPointerLocalScopeVariable() {
    this.getType().stripTopLevelSpecifiers() instanceof AutosarSharedPointer
  }
}

private class SharedPointerLocalAllocInitializerExpr extends Expr {
  SharedPointerLocalAllocInitializerExpr() {
    exists(AutosarSharedPointerLocalScopeVariable var, FunctionCall fc |
      fc = var.getAnAssignedValue() and
      not fc.getTarget() instanceof MoveConstructor and
      not fc.getTarget() instanceof CopyConstructor and
      this = fc
    )
  }
}

from AutosarSharedPointerLocalScopeVariable var, SharedPointerLocalAllocInitializerExpr src
where
  not isExcluded(var, SmartPointers1Package::sharedPointerUsedWithNoOwnershipSharingQuery()) and
  var.getAnAssignedValue() = src and
  not DataFlow::localExprFlow(src, varOwnershipSharingExpr(var.getType(), var.getFunction()))
select var,
  "The ownership of shared_ptr $@ is not shared within or passed out of the local scope of function $@.",
  var, var.getName(), var.getFunction(), var.getFunction().getQualifiedName()

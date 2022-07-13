/**
 * @id cpp/autosar/implicit-copy-assignment-operator-is-deprecated
 * @name A1-1-1: Implicit declaration of a class' copy-assignment operators is deprecated
 * @description The implicit declaration of a class' copy-assignment operators is deprecated.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a1-1-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import ImplicitMethods

Expr getCopyAssignmentOperatorCalls(Class c) {
  exists(Call call | result = call | call.getTarget() = getCopyAssignmentOperator(c))
  or
  // Sometimes, CodeQL misrepresents a copy-assignment operator call as an assignment.
  exists(AssignExpr ae | result = ae |
    ae.getLValue().getType() = c and ae.getRValue().getType() = c
  )
}

from Class c, Expr e
where
  not isExcluded(e, ToolchainPackage::implicitCopyAssignmentOperatorIsDeprecatedQuery()) and
  hasImplicitCopyAssignmentOperator(c) and
  e = getCopyAssignmentOperatorCalls(c) and
  (
    forall(CopyConstructor cc | cc = getCopyConstructor(c) | cc.isCompilerGenerated())
    or
    forall(Destructor d | d = c.getDestructor() | d.isCompilerGenerated())
  )
select e, "Use of implicit copy-assignment operator of class '" + c.getName() + "' is deprecated."

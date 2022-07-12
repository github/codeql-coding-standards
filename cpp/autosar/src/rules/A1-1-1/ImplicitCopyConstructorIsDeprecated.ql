/**
 * @id cpp/autosar/implicit-copy-constructor-is-deprecated
 * @name A1-1-1: Implicit declaration of a class' copy constructor is deprecated
 * @description The implicit declaration of a class' copy constructor is deprecated.
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

Expr getCopyConstructorCalls(Class c) {
  exists(Call call | result = call | call.getTarget() = getCopyConstructor(c))
  or
  // Sometimes, CodeQL misrepresents a copy-constructor call as an Initializer.
  exists(Initializer i | result = i.getExpr() |
    i.getExpr().(VariableAccess).getType() = c and
    i.getDeclaration().getADeclarationEntry().getType() = c
  )
}

from Class c, Expr e
where
  not isExcluded(e, ToolchainPackage::implicitCopyConstructorIsDeprecatedQuery()) and
  hasImplicitCopyConstructor(c) and
  e = getCopyConstructorCalls(c) and
  (
    forall(CopyAssignmentOperator cop | cop = getCopyAssignmentOperator(c) |
      cop.isCompilerGenerated()
    )
    or
    forall(Destructor d | d = c.getDestructor() | d.isCompilerGenerated())
  )
select e, "Use of implicit copy constructor of class '" + c.getName() + "' is deprecated."

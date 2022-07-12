/**
 * @id cpp/autosar/do-not-use-non-placement-delete
 * @name A18-5-2: Non-placement delete expressions shall not be used
 * @description Use of raw pointers returned by non-placement new can cause a memory leak if the
 *              developer fails to free the memory at an appropriate time.
 * @kind problem
 * @precision medium
 * @problem.severity recommendation
 * @tags external/autosar/id/a18-5-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class DeleteOrDeleteArrayExpr extends Expr {
  DeleteOrDeleteArrayExpr() {
    this instanceof DeleteExpr
    or
    this instanceof DeleteArrayExpr
  }
}

from DeleteOrDeleteArrayExpr d
where
  not isExcluded(d, AllocationsPackage::doNotUseNonPlacementDeleteQuery()) and
  not d.getEnclosingFunction() instanceof MemberFunction and
  not d.getEnclosingFunction() instanceof Operator and
  not d.getEnclosingFunction() instanceof OperatorNewAllocationFunction
select d, "Use of delete outside a manager or RAII class."

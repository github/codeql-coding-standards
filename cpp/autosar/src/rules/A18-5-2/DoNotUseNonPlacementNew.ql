/**
 * @id cpp/autosar/do-not-use-non-placement-new
 * @name A18-5-2: Non-placement new expressions shall not be used
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
import semmle.code.cpp.dataflow.DataFlow

from NewOrNewArrayExpr na
where
  not isExcluded(na, AllocationsPackage::doNotUseNonPlacementNewQuery()) and
  not exists(na.getPlacementPointer()) and
  not na.getEnclosingFunction() instanceof MemberFunction and
  not na.getEnclosingFunction() instanceof Operator and
  not na.getEnclosingFunction() instanceof OperatorNewAllocationFunction and
  // Not immediately passed to a member function (excluding shared/unique ptr which is not allowed)
  not exists(FunctionCall fc, MemberFunction mf |
    mf = fc.getTarget() and
    not mf.(Constructor).getDeclaringType().hasQualifiedName("std", ["shared_ptr", "unique_ptr"]) and
    fc.getAnArgument() = na
  )
select na, "Use of non-placement new expression outside a manager or RAII class."

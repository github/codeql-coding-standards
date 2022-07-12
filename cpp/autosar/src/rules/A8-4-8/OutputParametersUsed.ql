/**
 * @id cpp/autosar/output-parameters-used
 * @name A8-4-8: Output parameters shall not be used
 * @description Using output parameters can lead to undefined program behaviour, for example when
 *              they return dangling references.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a8-4-8
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/strict
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.FunctionParameter
import codingstandards.cpp.ConstHelpers
import codingstandards.cpp.Operator

/**
 * Non-const T& and T* `Parameter`s to `Function`s
 */
class NonConstReferenceOrPointerParameterCandidate extends FunctionParameter {
  NonConstReferenceOrPointerParameterCandidate() {
    this instanceof NonConstReferenceParameter
    or
    this instanceof NonConstPointerParameter
  }
}

pragma[inline]
predicate isFirstAccess(VariableAccess va) {
  not exists(VariableAccess otherVa |
    otherVa.getTarget() = va.getTarget() or
    otherVa.getQualifier().(VariableAccess).getTarget() = va.getTarget()
  |
    otherVa.getASuccessor() = va
  )
}

from NonConstReferenceOrPointerParameterCandidate p, VariableEffect ve
where
  not isExcluded(p, ConstPackage::outputParametersUsedQuery()) and
  ve.getTarget() = p and
  isFirstAccess(ve.getAnAccess()) and
  not ve instanceof AnyAssignOperation and
  not ve instanceof CrementOperation
select p, "Out parameter " + p.getName() + " that is modified before being read."

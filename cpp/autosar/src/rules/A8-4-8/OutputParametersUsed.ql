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
 * Holds if p is passed as a non-const reference or pointer and is modified.
 * This holds for in-out or out-only parameters.
 */
predicate isOutParameter(NonConstPointerorReferenceParameter p) {
  any(VariableEffect ve).getTarget() = p
}

/**
 * Holds if parameter `p` is a parameter to a user defined assignment operator that
 * is defined outside of a class body.
 * These require an in-out parameter as the first argument.
 */
predicate isNonMemberUserAssignmentParameter(NonConstPointerorReferenceParameter p) {
  p.getFunction() instanceof UserAssignmentOperator and
  not p.isMember()
}

/**
 * Holds if parameter `p` is a parameter to a stream insertion operator that
 * is defined outside of a class body.
 * These require an in-out parameter as the first argument.
 *
 * e.g., `std::ostream& operator<<(std::ostream& os, const T& obj)`
 */
predicate isStreamInsertionStreamParameter(NonConstPointerorReferenceParameter p) {
  exists(StreamInsertionOperator op | not op.isMember() | op.getParameter(0) = p)
}

/**
 * Holds if parameter `p` is a parameter to a stream insertion operator that
 * is defined outside of a class body.
 * These require an in-out parameter as the first argument and an out parameter for the second.
 *
 * e.g., `std::istream& operator>>(std::istream& is, T& obj)`
 */
predicate isStreamExtractionParameter(NonConstPointerorReferenceParameter p) {
  exists(StreamExtractionOperator op | not op.isMember() |
    op.getParameter(0) = p
    or
    op.getParameter(1) = p
  )
}

predicate isException(NonConstPointerorReferenceParameter p) {
  isNonMemberUserAssignmentParameter(p) and p.getIndex() = 0
  or
  isStreamInsertionStreamParameter(p)
  or
  isStreamExtractionParameter(p)
}

from NonConstPointerorReferenceParameter p
where
  not isExcluded(p, ConstPackage::outputParametersUsedQuery()) and
  isOutParameter(p) and
  not isException(p)
select p, "Out parameter '" + p.getName() + "' used."

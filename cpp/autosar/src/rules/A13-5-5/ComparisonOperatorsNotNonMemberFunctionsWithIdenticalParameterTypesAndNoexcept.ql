/**
 * @id cpp/autosar/comparison-operators-not-non-member-functions-with-identical-parameter-types-and-noexcept
 * @name A13-5-5: Comparison operators shall be non-member functions with identical parameter types and noexcept
 * @description Comparison operators shall be non-member functions with identical parameter types
 *              and noexcept.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a13-5-5
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

class ValidMemberUserComparisonOperator extends UserComparisonOperator {
  ValidMemberUserComparisonOperator() {
    not this.isMember() and
    this.getParameter(0).getType() = this.getParameter(1).getType() and
    this.isNoExcept()
  }
}

from UserComparisonOperator uco
where
  not isExcluded(uco,
    OperatorsPackage::comparisonOperatorsNotNonMemberFunctionsWithIdenticalParameterTypesAndNoexceptQuery()) and
  not uco instanceof ValidMemberUserComparisonOperator
select uco,
  "Comparison operators shall be non-member functions with identical parameter types and noexcept."

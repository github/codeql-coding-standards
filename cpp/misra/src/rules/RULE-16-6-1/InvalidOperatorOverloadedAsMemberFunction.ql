/**
 * @id cpp/misra/invalid-operator-overloaded-as-member-function
 * @name RULE-16-6-1: Symmetrical operators should only be implemented as non-member functions
 * @description Function resolution of operators overloaded as member functions is dependent on
 *              ordering and available conversions, which can lead to unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-16-6-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from MemberFunction f
where
  not isExcluded(f, Classes2Package::invalidOperatorOverloadedAsMemberFunctionQuery()) and
  f.hasName([
      "operator+", "operator-", "operator*", "operator/", "operator%", "operator==", "operator!=",
      "operator<", "operator<=", "operator>=", "operator>", "operator^", "operator&", "operator|",
      "operator&&", "operator||"
    ]) and
  f.getNumberOfParameters() = 1
select f,
  "Symmetrical operator '" + f.getName() + "' should be implemented as a non-member function."

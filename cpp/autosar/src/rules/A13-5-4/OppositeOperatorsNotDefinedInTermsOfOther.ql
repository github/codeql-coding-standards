/**
 * @id cpp/autosar/opposite-operators-not-defined-in-terms-of-other
 * @name A13-5-4: If two opposite operators are defined, one shall be defined in terms of the other
 * @description If two opposite operators are defined, one shall be defined in terms of the other.
 *              This simplifies maintenance and prevents accidental errors during development.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a13-5-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

string oppositeOperator(UserComparisonOperator o) {
  if o.getName() = "operator=="
  then result = "operator!="
  else
    if o.getName() = "operator!="
    then result = "operator=="
    else result = ""
}

predicate hasSameSignatureAndReturnType(UserComparisonOperator o1, UserComparisonOperator o2) {
  o1.getType() = o2.getType() and o1.getParameterString() = o2.getParameterString()
}

from UserComparisonOperator o, UserComparisonOperator opposite
where
  not isExcluded(opposite,
    OperatorInvariantsPackage::oppositeOperatorsNotDefinedInTermsOfOtherQuery()) and
  hasSameSignatureAndReturnType(o, opposite) and
  (o.hasName("operator==") or o.hasName("operator!=")) and
  opposite.hasName(oppositeOperator(o)) and
  not (
    o.getACallToThisFunction().getEnclosingFunction() = opposite or
    opposite.getACallToThisFunction().getEnclosingFunction() = o
  )
select opposite,
  "Comparison operator " + o.getDeclaringType().getSimpleName() + "::" + o.getName() +
    " is not defined in terms of its opposite " + opposite.getDeclaringType().getSimpleName() + "::"
    + opposite.getName()

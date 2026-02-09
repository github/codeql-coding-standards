/**
 * @id cpp/cert/do-not-cast-to-an-out-of-range-enumeration-value
 * @name INT50-CPP: Do not cast to an out-of-range enumeration value
 * @description Casting to an out-of-range enumeration value leads to unspecified or undefined
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/int50-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Enums
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import codingstandards.cpp.SimpleRangeAnalysisCustomizations

from Cast c, Enum e, string description
where
  not isExcluded(c, TypeRangesPackage::doNotCastToAnOutOfRangeEnumerationValueQuery()) and
  // Conversion from an integral type to an enum type
  c.getExpr().getType().getUnspecifiedType() instanceof IntegralType and
  c.getType().getUnspecifiedType() = e and
  not (
    // The deduced bound for the expression is within the type range for the explicit type
    upperBound(c.getExpr()) <= Enums::getValueRangeUpperBound(e) and
    lowerBound(c.getExpr()) >= Enums::getValueRangeLowerBound(e)
  ) and
  // Not a compile time constant with the same value as an existing enum constant
  not exists(float enumConstantValue |
    enumConstantValue = Enums::getEnumConstantValue(e.getAnEnumConstant())
  |
    // Expression is a constant
    c.getExpr().getValue().toFloat() = enumConstantValue
    or
    // Range analysis has precise bounds
    enumConstantValue = upperBound(c.getExpr()) and
    enumConstantValue = lowerBound(c.getExpr())
  ) and
  (
    if exists(upperBound(c.getExpr()))
    then
      description =
        "Cast to enum $@ with value range " + Enums::getValueRangeLowerBound(e) + "..." +
          Enums::getValueRangeUpperBound(e) + " from expression with wider value range " +
          lowerBound(c.getExpr()) + "..." + upperBound(c.getExpr()) + " in function " +
          c.getEnclosingFunction().getName() + "."
    else
      description =
        "Cast to enum $@ with value range " + Enums::getValueRangeLowerBound(e) + "..." +
          Enums::getValueRangeUpperBound(e) +
          " from expression with a potentially wider value range."
  )
select c, description, e, e.getName()

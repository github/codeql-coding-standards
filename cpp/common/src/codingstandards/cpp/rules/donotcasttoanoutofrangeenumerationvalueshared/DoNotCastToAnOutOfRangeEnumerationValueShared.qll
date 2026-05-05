/**
 * Provides a configurable module DoNotCastToAnOutOfRangeEnumerationValueShared with a `problems` predicate
 * for the following issue:
 * Casting to an out-of-range enumeration value leads to unspecified or undefined
 * behavior.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Enums
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import codingstandards.cpp.SimpleRangeAnalysisCustomizations

signature module DoNotCastToAnOutOfRangeEnumerationValueSharedConfigSig {
  Query getQuery();
}

module DoNotCastToAnOutOfRangeEnumerationValueShared<
  DoNotCastToAnOutOfRangeEnumerationValueSharedConfigSig Config>
{
  query predicate problems(Cast c, string description, Enum e, string enumName) {
    not isExcluded(c, Config::getQuery()) and
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
    enumName = e.getName() and
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
  }
}

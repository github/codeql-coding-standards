/**
 * @id cpp/autosar/non-enumerator-enum-value
 * @name A7-2-1: An expression with enum underlying type shall only have values corresponding to the enumerators of the enumeration
 * @description An expression with enum underlying type shall only have values corresponding to the
 *              enumerators of the enumeration.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a7-2-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Enums
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

from Cast c, Enum e, string description
where
  not isExcluded(c, TypeRangesPackage::nonEnumeratorEnumValueQuery()) and
  // Conversion from an integral type to an enum type
  c.getExpr().getType().getUnspecifiedType() instanceof IntegralType and
  c.getType().getUnspecifiedType() = e and
  not (
    // The deduced bound for the expression is within the min/max values of the enum
    upperBound(c.getExpr()) <= Enums::getMaxEnumValue(e) and
    lowerBound(c.getExpr()) >= Enums::getMinEnumValue(e) and
    // And the enum is contiguous, so it's guaranteed to be a valid enumeration constant
    Enums::isContiguousEnum(e)
  ) and
  // Not a constant with the same value as an existing enum constant
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
    if exists(c.getExpr().getValue())
    then
      description =
        "Cast to enum $@ with from expression with value " + c.getExpr().getValue().toFloat() +
          "_+ which is not one of the enumerator values in function " +
          c.getEnclosingFunction().getName() + "."
    else
      if exists(upperBound(c.getExpr()))
      then
        description =
          "Cast to enum $@ with from expression with range " + lowerBound(c.getExpr()) + "..." +
            upperBound(c.getExpr()) + " which may not be one of the enumerator values in function " +
            c.getEnclosingFunction().getName() + "."
      else
        description =
          "Cast to enum $@ from expression with a value which may not be one of the enumerator values in function "
            + c.getEnclosingFunction().getName() + "."
  )
select c, description, e, e.getName()

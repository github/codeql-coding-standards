/**
 * @id cpp/autosar/signed-char-and-unsigned-char-type-shall-only-be-used-for-the-storage-and-use-of-numeric-values
 * @name M5-0-12: Signed char and unsigned char type shall only be used for the storage and use of numeric values
 * @description The signedness of the plain char type is implementation defined and thus signed char
 *              and unsigned char should only be used for numeric data and the plain char type may
 *              only be used for character data.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m5-0-12
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Conversion c
where
  not isExcluded(c,
    StringsPackage::signedCharAndUnsignedCharTypeShallOnlyBeUsedForTheStorageAndUseOfNumericValuesQuery()) and
  /* 1. Focus on implicit conversions only (explicit conversions are acceptable). */
  c.isImplicit() and
  /* 2. The target type is explicitly signed or unsigned char. */
  (
    c.getUnspecifiedType() instanceof SignedCharType or
    c.getUnspecifiedType() instanceof UnsignedCharType
  ) and
  /* 3. Check if the source expression is a plain char type, i.e. not explicitly signed / unsigned. */
  c.getExpr().getUnspecifiedType() instanceof PlainCharType
select c,
  "This expression of plain char type is implicitly converted to '" +
    c.getUnspecifiedType().getName() + "'."

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

from Variable v, Expr aexp
where
  not isExcluded(v,
    StringsPackage::signedCharAndUnsignedCharTypeShallOnlyBeUsedForTheStorageAndUseOfNumericValuesQuery()) and
  // We find cases where it is an explicitly signed char type with an assignment
  // to a non-numeric type. NOTE: This rule addresses cases where the char type
  // is used character data only, the rule does not explicitly cover this.
  // Please see M5-0-11 for explicit handling of this case. Get types that are
  // char, except for ones that are 'plain', meaning the sign is explicit.
  (
    v.getUnspecifiedType() instanceof SignedCharType or
    v.getUnspecifiedType() instanceof UnsignedCharType
  ) and
  // Identify places where these explicitly signed types are being assigned to a
  // non-numeric type.
  aexp = v.getAnAssignedValue() and
  aexp.getUnspecifiedType() instanceof CharType
select aexp,
  "Assignment of an non-integer type to variable $@ which is a variable with an explicitly signed char type",
  v, v.getName()

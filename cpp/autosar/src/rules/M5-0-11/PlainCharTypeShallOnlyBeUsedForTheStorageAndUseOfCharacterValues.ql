/**
 * @id cpp/autosar/plain-char-type-shall-only-be-used-for-the-storage-and-use-of-character-values
 * @name M5-0-11: The plain char type shall only be used for the storage and use of character values
 * @description The signedness of type char is implementation defined and therefore assigning
 *              non-character values to plain char types can cause undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m5-0-11
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Variable v, Expr aexp
where
  not isExcluded(v,
    StringsPackage::plainCharTypeShallOnlyBeUsedForTheStorageAndUseOfCharacterValuesQuery()) and
  // restrict this to JUST the cases where it is not explicitly
  // signed or unsigned
  v.getUnspecifiedType() instanceof PlainCharType and
  aexp = v.getAnAssignedValue() and
  not aexp.getUnspecifiedType() instanceof CharType
select aexp,
  "Assignment of a " + aexp.getType().getName() +
    " type to variable $@ which is a variable of type char", v, v.getName()

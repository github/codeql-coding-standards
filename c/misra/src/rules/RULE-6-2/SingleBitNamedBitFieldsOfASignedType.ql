/**
 * @id c/misra/single-bit-named-bit-fields-of-a-signed-type
 * @name RULE-6-2: Single-bit named bit fields shall not be of a signed type
 * @description Single-bit named bit fields carry no useful information and therefore should not be
 *              declared or used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-2
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

/*
 * Check if the DECLARED bit-fields is a single bit, because Rule 6.2 also intends to catch confusion on the programmers' part. Consider:
 *
 * struct S {
 *  int32_t x: 1;
 * }
 *
 * In this case, field x is essentially of 32 bits, but is declared as 1 bit and its type int32_t is signed. Therefore, it indicates confusion by the programmer, which is exactly what this rule intends to find.
 */

from BitField bitField
where
  not isExcluded(bitField, BitfieldTypesPackage::singleBitNamedBitFieldsOfASignedTypeQuery()) and
  bitField.getDeclaredNumBits() = 1 and // Single-bit,
  not bitField.isAnonymous() and // named,
  bitField.getType().(IntegralType).isSigned() // but its type is signed.
select bitField,
  "Single-bit bit-field named " + bitField.toString() + " has a signed type " + bitField.getType() +
    "."

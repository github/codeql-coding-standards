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

predicate isSigned(Type type) {
  /* Check if it's a fixed number type, because declaring fixed number types like int8_t as 1 bit is obviously absurd */
  type instanceof FixedWidthIntegralType or 
  /* Check if it's EXPLICITLY signed, because according to Rule 6.1, 'int' may be either signed or unsigned depending on the implementation. In the latter case, the query would lead to false positives. */
  type instanceof IntegralType and
  type.(IntegralType).isExplicitlySigned()
}

/* Check if the DECLARED bit-fields is a single bit, because Rule 6.2 also intends to catch confusion on the programmers' part. Consider:

struct S {
  int32_t x: 1;
}

In this case, field x is essentially of 32 bits, but is declared as 1 bit and its type int32_t is signed. Therefore, it indicates confusion by the programmer, which is exactly what this rule intends to find. */
predicate isSingleBit(BitField bitField) {
  bitField.getDeclaredNumBits() = 1
}

from BitField bitField
where
  not isExcluded(bitField, BitfieldTypesPackage::singleBitNamedBitFieldsOfASignedTypeQuery()) and
  isSingleBit(bitField) and // Single-bit,
  not bitField.isAnonymous() and // named,
  isSigned(bitField.getType()) // but its type is signed.
select bitField, "Single-bit bit-field named " + bitField.toString() + " has a signed type " + bitField.getType() + "."
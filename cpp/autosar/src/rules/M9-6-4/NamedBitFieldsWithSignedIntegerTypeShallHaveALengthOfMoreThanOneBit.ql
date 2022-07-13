/**
 * @id cpp/autosar/named-bit-fields-with-signed-integer-type-shall-have-a-length-of-more-than-one-bit
 * @name M9-6-4: Named bit-fields with signed integer type shall have a length of more than one bit
 * @description Named bit-fields with signed integer type shall have a length of more than one bit.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m9-6-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from BitField bf
where
  not isExcluded(bf,
    RepresentationPackage::namedBitFieldsWithSignedIntegerTypeShallHaveALengthOfMoreThanOneBitQuery()) and
  bf.getType().getUnderlyingType().(IntegralType).isSigned() and
  bf.getNumBits() < 2 and
  bf.getName() != "(unnamed bitfield)"
select bf, "A named bit-field with signed integral type should have at least 2 bits of storage "

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
import codingstandards.cpp.rules.namedbitfieldswithsignedintegertype_shared.NamedBitFieldsWithSignedIntegerType_shared

class SingleBitNamedBitFieldsOfASignedTypeQuery extends NamedBitFieldsWithSignedIntegerType_sharedSharedQuery
{
  SingleBitNamedBitFieldsOfASignedTypeQuery() {
    this = BitfieldTypesPackage::singleBitNamedBitFieldsOfASignedTypeQuery()
  }
}

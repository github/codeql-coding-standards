/**
 * @id c/misra/bit-fields-shall-only-be-declared-with-an-appropriate-type
 * @name RULE-6-1: Bit-fields shall only be declared with an appropriate type
 * @description Declaring bit-fields on types other than appropriate ones causes
 *              implementation-specific or undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-1
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.bitfieldshallhaveanappropriatetype.BitFieldShallHaveAnAppropriateType

class BitFieldsShallOnlyBeDeclaredWithAnAppropriateTypeQuery extends BitFieldShallHaveAnAppropriateTypeSharedQuery
{
  BitFieldsShallOnlyBeDeclaredWithAnAppropriateTypeQuery() {
    this = BitfieldTypesPackage::bitFieldsShallOnlyBeDeclaredWithAnAppropriateTypeQuery()
  }
}

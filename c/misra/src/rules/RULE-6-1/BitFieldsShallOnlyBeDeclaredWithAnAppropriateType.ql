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
import codingstandards.cpp.rules.bitfieldshallhaveanappropriatetype_shared.BitFieldShallHaveAnAppropriateType_shared

class BitFieldsShallOnlyBeDeclaredWithAnAppropriateTypeQuery extends BitFieldShallHaveAnAppropriateType_sharedSharedQuery {
  BitFieldsShallOnlyBeDeclaredWithAnAppropriateTypeQuery() {
    this = BitfieldTypesPackage::bitFieldsShallOnlyBeDeclaredWithAnAppropriateTypeQuery()
  }
}

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

predicate isAppropriatePrimitive(Type type) {
  /* An appropriate primitive types to which a bit-field can be declared. */
  type instanceof IntType and
  (
    type.(IntegralType).isExplicitlySigned() or
    type.(IntegralType).isExplicitlyUnsigned()
  )
  or
  type instanceof BoolType
}

from BitField bitField
where
  not isExcluded(bitField,
    BitfieldTypesPackage::bitFieldsShallOnlyBeDeclaredWithAnAppropriateTypeQuery()) and
  /* A violation would neither be an appropriate primitive type nor an appropriate typedef. */
  not isAppropriatePrimitive(bitField.getType().resolveTypedefs())
select bitField, "Bit-field " + bitField + " is declared on type " + bitField.getType() + "."

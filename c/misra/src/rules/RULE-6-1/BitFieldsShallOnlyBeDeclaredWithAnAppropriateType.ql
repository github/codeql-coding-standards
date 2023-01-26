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

predicate isSignedOrUnsignedInt(Type type) {
    type instanceof IntType and
    (type.(IntegralType).isExplicitlySigned() or
    type.(IntegralType).isExplicitlyUnsigned())
}

predicate isAppropriatePrimitive(Type type) {
    /* An appropriate primitive types to which a bit-field can be declared. */
    isSignedOrUnsignedInt(type) or type instanceof BoolType
}

predicate isAppropriateTypedef(Type type) {
    type instanceof TypedefType and
    /* An appropriate typedef should be an alias to an appropriate primitive type. */
    isAppropriatePrimitive(type.(TypedefType).resolveTypedefs())
}

from BitField bitField
where
not isExcluded(bitField, TypesPackage::bitFieldsShallOnlyBeDeclaredWithAnAppropriateTypeQuery()) and
/* A violation would neither an appropriate primitive type nor an appropriate typedef. */
not (isAppropriatePrimitive(bitField.getType()) or isAppropriateTypedef(bitField.getType()))
select bitField, "Bit-field " + bitField + " is declared on type " + bitField + "."
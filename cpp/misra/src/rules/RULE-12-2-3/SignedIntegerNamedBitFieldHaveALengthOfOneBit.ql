/**
 * @id cpp/misra/signed-integer-named-bit-field-have-a-length-of-one-bit
 * @name RULE-12-2-3: A named bit-field with signed integer type shall not have a length of one bit
 * @description A named bit-field with signed integer type shall not have a length of one bit.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-2-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.namedbitfieldswithsignedintegertype.NamedBitFieldsWithSignedIntegerType

class SignedIntegerNamedBitFieldHaveALengthOfOneBitQuery extends NamedBitFieldsWithSignedIntegerTypeSharedQuery
{
  SignedIntegerNamedBitFieldHaveALengthOfOneBitQuery() {
    this = ImportMisra23Package::signedIntegerNamedBitFieldHaveALengthOfOneBitQuery()
  }
}

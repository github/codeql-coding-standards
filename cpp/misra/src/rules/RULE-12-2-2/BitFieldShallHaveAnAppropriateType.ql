/**
 * @id cpp/misra/bit-field-shall-have-an-appropriate-type
 * @name RULE-12-2-2: A bit-field shall have an appropriate type
 * @description A bit-field shall have an appropriate type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-2-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.bitfieldshallhaveanappropriatetype.BitFieldShallHaveAnAppropriateType

class BitFieldShallHaveAnAppropriateTypeQuery extends BitFieldShallHaveAnAppropriateTypeSharedQuery {
  BitFieldShallHaveAnAppropriateTypeQuery() {
    this = ImportMisra23Package::bitFieldShallHaveAnAppropriateTypeQuery()
  }
}

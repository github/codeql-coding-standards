/**
 * @id cpp/misra/non-unique-enumeration-constant
 * @name RULE-11-6-3: Within an enumerator list, the value of an implicitly-specified enumeration constant shall be unique
 * @description Within an enumerator list, the value of an implicitly-specified enumeration constant
 *              shall be unique.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-6-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.nonuniqueenumerationconstant.NonUniqueEnumerationConstant

class NonUniqueEnumerationConstantQuery extends NonUniqueEnumerationConstantSharedQuery {
  NonUniqueEnumerationConstantQuery() {
    this = ImportMisra23Package::nonUniqueEnumerationConstantQuery()
  }
}

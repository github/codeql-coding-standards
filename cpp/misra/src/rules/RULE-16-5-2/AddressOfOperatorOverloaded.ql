/**
 * @id cpp/misra/address-of-operator-overloaded
 * @name RULE-16-5-2: The address-of operator shall not be overloaded
 * @description The address-of operator shall not be overloaded.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-16-5-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.addressofoperatoroverloaded_shared.AddressOfOperatorOverloaded_shared

class AddressOfOperatorOverloadedQuery extends AddressOfOperatorOverloaded_sharedSharedQuery {
  AddressOfOperatorOverloadedQuery() {
    this = ImportMisra23Package::addressOfOperatorOverloadedQuery()
  }
}

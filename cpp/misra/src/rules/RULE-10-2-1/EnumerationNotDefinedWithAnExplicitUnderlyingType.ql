/**
 * @id cpp/misra/enumeration-not-defined-with-an-explicit-underlying-type
 * @name RULE-10-2-1: An enumeration shall be defined with an explicit underlying type
 * @description An enumeration shall be defined with an explicit underlying type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-2-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.enumerationnotdefinedwithanexplicitunderlyingtype_shared.EnumerationNotDefinedWithAnExplicitUnderlyingType_shared

class EnumerationNotDefinedWithAnExplicitUnderlyingTypeQuery extends EnumerationNotDefinedWithAnExplicitUnderlyingType_sharedSharedQuery {
  EnumerationNotDefinedWithAnExplicitUnderlyingTypeQuery() {
    this = ImportMisra23Package::enumerationNotDefinedWithAnExplicitUnderlyingTypeQuery()
  }
}

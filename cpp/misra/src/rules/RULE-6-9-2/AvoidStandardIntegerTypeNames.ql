/**
 * @id cpp/misra/avoid-standard-integer-type-names
 * @name RULE-6-9-2: The names of the standard integer types should not be used
 * @description Using standard signed and unsigned integer type names instead of specified width
 *              types makes storage requirements unclear and implementation-dependent.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-9-2
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.variablewidthintegertypesused.VariableWidthIntegerTypesUsed

class AvoidStandardIntegerTypeNamesQuery extends VariableWidthIntegerTypesUsedSharedQuery {
  AvoidStandardIntegerTypeNamesQuery() {
    this = BannedAPIsPackage::avoidStandardIntegerTypeNamesQuery()
  }
}

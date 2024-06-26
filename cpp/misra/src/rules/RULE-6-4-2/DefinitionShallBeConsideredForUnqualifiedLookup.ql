/**
 * @id cpp/misra/definition-shall-be-considered-for-unqualified-lookup
 * @name RULE-6-4-2: Using declaration followed by new definition
 * @description A using declaration that makes a symbol available for unqualified lookup does not
 *              included definitions defined after the using declaration which can result in
 *              unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-4-2
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.definitionnotconsideredforunqualifiedlookup_shared.DefinitionNotConsideredForUnqualifiedLookup_shared

class DefinitionShallBeConsideredForUnqualifiedLookupQuery extends DefinitionNotConsideredForUnqualifiedLookup_sharedSharedQuery
{
  DefinitionShallBeConsideredForUnqualifiedLookupQuery() {
    this = ImportMisra23Package::definitionShallBeConsideredForUnqualifiedLookupQuery()
  }
}

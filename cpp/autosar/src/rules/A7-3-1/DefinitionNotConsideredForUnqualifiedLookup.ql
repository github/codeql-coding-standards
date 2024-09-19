/**
 * @id cpp/autosar/definition-not-considered-for-unqualified-lookup
 * @name A7-3-1: Using declaration followed by new definition
 * @description A using declaration that makes a symbol available for unqualified lookup does not
 *              included definitions defined after the using declaration which can result in
 *              unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a7-3-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.definitionnotconsideredforunqualifiedlookup.DefinitionNotConsideredForUnqualifiedLookup

class DefinitionNotConsideredForUnqualifiedLookupQuery extends DefinitionNotConsideredForUnqualifiedLookupSharedQuery
{
  DefinitionNotConsideredForUnqualifiedLookupQuery() {
    this = ScopePackage::definitionNotConsideredForUnqualifiedLookupQuery()
  }
}

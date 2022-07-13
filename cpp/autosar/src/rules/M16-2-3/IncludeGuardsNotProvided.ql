/**
 * @id cpp/autosar/include-guards-not-provided
 * @name M16-2-3: Include guards shall be provided
 * @description Using anything other than a standard include guard form can make code confusing and
 *              can lead to multiple or conflicting definitions.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-2-3
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.includeguardsnotused.IncludeGuardsNotUsed

class PrecautionIncludeGuardsNotProvidedQuery extends IncludeGuardsNotUsedSharedQuery {
  PrecautionIncludeGuardsNotProvidedQuery() {
    this = IncludesPackage::includeGuardsNotProvidedQuery()
  }
}

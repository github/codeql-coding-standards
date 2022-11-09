/**
 * @id c/misra/precaution-include-guards-not-provided
 * @name DIR-4-10: Precautions shall be taken in order to prevent the contents of a header file being included more than once
 * @description Using anything other than a standard include guard form can make code confusing and
 *              can lead to multiple or conflicting definitions.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/dir-4-10
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.includeguardsnotused.IncludeGuardsNotUsed

class PrecautionIncludeGuardsNotProvidedQuery extends IncludeGuardsNotUsedSharedQuery {
  PrecautionIncludeGuardsNotProvidedQuery() {
    this = Preprocessor2Package::precautionIncludeGuardsNotProvidedQuery()
  }
}

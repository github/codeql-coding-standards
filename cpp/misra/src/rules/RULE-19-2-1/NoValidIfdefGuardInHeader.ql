/**
 * @id cpp/misra/no-valid-ifdef-guard-in-header
 * @name RULE-19-2-1: Precautions shall be taken in order to prevent the contents of a header file being included more
 * @description Precautions shall be taken in order to prevent the contents of a header file being
 *              included more than once.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-2-1
 *       scope/single-translation-unit
 *       maintainability
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.includeguardsnotused.IncludeGuardsNotUsed

class NoValidIfdefGuardInHeaderQuery extends IncludeGuardsNotUsedSharedQuery {
  NoValidIfdefGuardInHeaderQuery() { this = PreprocessorPackage::noValidIfdefGuardInHeaderQuery() }
}

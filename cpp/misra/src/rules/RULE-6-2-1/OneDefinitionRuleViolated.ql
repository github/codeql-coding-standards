/**
 * @id cpp/misra/one-definition-rule-violated
 * @name RULE-6-2-1: The one-definition rule shall not be violated
 * @description The one-definition rule specifies when there should be a single definition of an
 *              element and a violation of that rule leads to undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-2-1
 *       correctness
 *       scope/system
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.onedefinitionruleviolation.OneDefinitionRuleViolation

class OneDefinitionRuleViolatedQuery extends OneDefinitionRuleViolationSharedQuery {
  OneDefinitionRuleViolatedQuery() {
    this = ImportMisra23Package::oneDefinitionRuleViolatedQuery()
  }
}

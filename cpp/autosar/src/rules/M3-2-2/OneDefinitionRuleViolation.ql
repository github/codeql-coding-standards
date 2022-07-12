/**
 * @id cpp/autosar/one-definition-rule-violation
 * @name M3-2-2: The one-definition rule shall not be violated
 * @description The one-definition rule specifies when there should be a single definition of an
 *              element and a violation of that rule leads to undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/autosar/id/m3-2-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.onedefinitionruleviolation.OneDefinitionRuleViolation

class OneDefinitionRuleViolationQuery extends OneDefinitionRuleViolationSharedQuery {
  OneDefinitionRuleViolationQuery() { this = ScopePackage::oneDefinitionRuleViolationQuery() }
}

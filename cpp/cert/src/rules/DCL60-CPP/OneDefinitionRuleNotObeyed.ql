/**
 * @id cpp/cert/one-definition-rule-not-obeyed
 * @name DCL60-CPP: Obey the one-definition rule
 * @description The one-definition rule specifies when there should be a single definition of an
 *              element and a violation of that rule leads to undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/dcl60-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p3
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.onedefinitionruleviolation.OneDefinitionRuleViolation

class OneDefinitionRuleNotObeyedQuery extends OneDefinitionRuleViolationSharedQuery {
  OneDefinitionRuleNotObeyedQuery() { this = ScopePackage::oneDefinitionRuleNotObeyedQuery() }
}

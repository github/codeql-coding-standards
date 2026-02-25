/**
 * @id cpp/misra/violations-of-one-definition-rule-misra
 * @name RULE-6-2-4: A header file shall not contain definitions of functions or objects that are non-inline and have external linkage
 * @description Placing the definitions of functions or objects that are non-inline and have
 *              external linkage can lead to violations of the ODR and can lead to undefined
 *              behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-6-2-4
 *       correctness
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.violationsofonedefinitionrule.ViolationsOfOneDefinitionRule

class ViolationsOfOneDefinitionRuleMisraQuery extends ViolationsOfOneDefinitionRuleSharedQuery {
  ViolationsOfOneDefinitionRuleMisraQuery() {
    this = Linkage2Package::violationsOfOneDefinitionRuleMisraQuery()
  }
}

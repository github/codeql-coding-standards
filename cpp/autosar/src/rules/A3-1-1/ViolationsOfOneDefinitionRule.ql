/**
 * @id cpp/autosar/violations-of-one-definition-rule
 * @name A3-1-1: It shall be possible to include any header file in multiple translation units without violating the One Definition Rule
 * @description Defining externally linked objects or functions in header files can result in
 *              violations of the One Definition Rule (i.e., linkage failure or undefined behaviour
 *              can result).
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a3-1-1
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.violationsofonedefinitionrule.ViolationsOfOneDefinitionRule

class ViolationsOfOneDefinitionRuleQuery extends ViolationsOfOneDefinitionRuleSharedQuery {
  ViolationsOfOneDefinitionRuleQuery() {
    this = IncludesPackage::violationsOfOneDefinitionRuleQuery()
  }
}

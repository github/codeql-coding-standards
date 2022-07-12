/**
 * @id cpp/autosar/switch-less-than-two-cases
 * @name A6-4-1: A switch statement shall have at least two case-clauses, distinct from the default label
 * @description A switch statement constructed with less than two case-clauses can be expressed as
 *              an if statement more naturally.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a6-4-1
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from SwitchStmt switchStmt, int nonDefaultCases
where
  nonDefaultCases = count(SwitchCase sc | switchStmt.getASwitchCase() = sc and not sc.isDefault()) and
  nonDefaultCases < 2
select switchStmt,
  "Unnecessary use of switch statement with " + nonDefaultCases + " non default case(s)."

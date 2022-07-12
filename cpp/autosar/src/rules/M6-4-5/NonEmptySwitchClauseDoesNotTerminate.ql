/**
 * @id cpp/autosar/non-empty-switch-clause-does-not-terminate
 * @name M6-4-5: An unconditional throw or break statement shall terminate every non-empty switch-clause
 * @description If a non empty switch clause does not have a throw/break statement, it will by
 *              default fall into the next switch clause. This can lead to unspecified behaviour. A
 *              switch clause shall always have a throw or break.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-4-5
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SwitchStatement

from CaseDoesNotTerminate case
where not isExcluded(case, ConditionalsPackage::nonEmptySwitchClauseDoesNotTerminateQuery())
select case, "This $@ clause does not terminate.", case, "case"

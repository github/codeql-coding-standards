/**
 * @id cpp/misra/result-of-an-assignment-operator-should-not-be-used
 * @name RULE-8-18-2: The result of an assignment operator should not be used
 * @description The result of an assignment operator should not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-18-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.resultofanassignmentoperatorshouldnotbeused.ResultOfAnAssignmentOperatorShouldNotBeUsed

class ResultOfAnAssignmentOperatorShouldNotBeUsedQuery extends ResultOfAnAssignmentOperatorShouldNotBeUsedSharedQuery
{
  ResultOfAnAssignmentOperatorShouldNotBeUsedQuery() {
    this = ImportMisra23Package::resultOfAnAssignmentOperatorShouldNotBeUsedQuery()
  }
}

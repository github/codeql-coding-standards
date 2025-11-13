/**
 * @id c/misra/result-of-an-assignment-operator-should-not-be-used
 * @name RULE-13-4: The result of an assignment operator should not be used
 * @description The use of an assignment operator can impair the readability of the code and the
 *              introduced side effect may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-4
 *       correctness
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/advisory
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.resultofanassignmentoperatorshouldnotbeused.ResultOfAnAssignmentOperatorShouldNotBeUsed

class ResultOfAnAssignmentOperatorShouldNotBeUsedQuery extends ResultOfAnAssignmentOperatorShouldNotBeUsedSharedQuery
{
  ResultOfAnAssignmentOperatorShouldNotBeUsedQuery() {
    this = SideEffects1Package::resultOfAnAssignmentOperatorShouldNotBeUsedQuery()
  }
}

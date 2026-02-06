/**
 * @id cpp/misra/pointer-compared-between-different-arrays
 * @name RULE-8-9-1: The built-in relational operators >, >=, < and <= shall not be applied to objects of pointer type
 * @description Pointer comparison should be done between ones that belong to a same array.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-8-9-1
 *       scope/system
 *       correctness
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.donotuserelationaloperatorswithdifferingarrays.DoNotUseRelationalOperatorsWithDifferingArrays

class PointerComparedBetweenDifferentArraysQuery extends DoNotUseRelationalOperatorsWithDifferingArraysSharedQuery
{
  PointerComparedBetweenDifferentArraysQuery() {
    this = Memory3Package::pointerComparedBetweenDifferentArraysQuery()
  }
}

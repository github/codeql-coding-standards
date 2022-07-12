/**
 * @id c/misra/relational-operator-compares-pointer-to-different-array
 * @name RULE-18-3: The relational operators >, >=, < and <= shall not be applied to pointers unless they point to the same object
 * @description The relational operators >, >=, <, <= applied to pointers produces undefined
 *              behavior, except where they point to the same object.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-18-3
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.donotuserelationaloperatorswithdifferingarrays.DoNotUseRelationalOperatorsWithDifferingArrays

class RelationalOperatorComparesPointerToDifferentArrayQuery extends DoNotUseRelationalOperatorsWithDifferingArraysSharedQuery {
  RelationalOperatorComparesPointerToDifferentArrayQuery() {
    this = Pointers1Package::relationalOperatorComparesPointerToDifferentArrayQuery()
  }
}

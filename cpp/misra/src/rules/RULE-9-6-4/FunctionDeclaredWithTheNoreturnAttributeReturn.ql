/**
 * @id cpp/misra/function-declared-with-the-noreturn-attribute-return
 * @name RULE-9-6-4: A function declared with the [[noreturn]] attribute shall not return
 * @description A function with the [[noreturn]] attribute that returns leads to undefined
 *              behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-6-4
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.functionnoreturnattributecondition.FunctionNoReturnAttributeCondition

class FunctionDeclaredWithTheNoreturnAttributeReturnQuery extends FunctionNoReturnAttributeConditionSharedQuery {
  FunctionDeclaredWithTheNoreturnAttributeReturnQuery() {
    this = ImportMisra23Package::functionDeclaredWithTheNoreturnAttributeReturnQuery()
  }
}

/**
 * @id cpp/autosar/function-no-return-attribute-condition-autosar
 * @name A7-6-1: Functions declared with the [[noreturn]] attribute shall not return
 * @description A function with the [[noreturn]] attribute that returns leads to undefined
 *              behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a7-6-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.functionnoreturnattributecondition.FunctionNoReturnAttributeCondition

class FunctionNoReturnAttributeConditionAutosarQuery extends FunctionNoReturnAttributeConditionSharedQuery {
  FunctionNoReturnAttributeConditionAutosarQuery() {
    this = FunctionsPackage::functionNoReturnAttributeConditionAutosarQuery()
  }
}

/**
 * @id cpp/autosar/function-return-automatic-var-condition
 * @name M7-5-1: A function shall not return a reference or a pointer to an automatic variable (including parameters)
 * @description Functions that return a reference or a pointer to an automatic variable (including
 *              parameters) potentially lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m7-5-1
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 *       coding-standards/baseline/safety
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.returnreferenceorpointertoautomaticlocalvariable.ReturnReferenceOrPointerToAutomaticLocalVariable

class FunctionReturnAutomaticVarConditionQuery extends ReturnReferenceOrPointerToAutomaticLocalVariableSharedQuery
{
  FunctionReturnAutomaticVarConditionQuery() {
    this = FunctionsPackage::functionReturnAutomaticVarConditionQuery()
  }
}

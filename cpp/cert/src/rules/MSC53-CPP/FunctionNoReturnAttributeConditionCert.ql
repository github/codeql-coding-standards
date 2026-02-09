/**
 * @id cpp/cert/function-no-return-attribute-condition-cert
 * @name MSC53-CPP: Do not return from a function declared [[noreturn]]
 * @description A function with the [[noreturn]] attribute that returns leads to undefined
 *              behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc53-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.functionnoreturnattributecondition.FunctionNoReturnAttributeCondition

class FuntionNoReturnAttributeConditionCertQuery extends FunctionNoReturnAttributeConditionSharedQuery
{
  FuntionNoReturnAttributeConditionCertQuery() {
    this = FunctionsPackage::functionNoReturnAttributeConditionCertQuery()
  }
}

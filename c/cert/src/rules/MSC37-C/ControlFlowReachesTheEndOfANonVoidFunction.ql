/**
 * @id c/cert/control-flow-reaches-the-end-of-a-non-void-function
 * @name MSC37-C: Ensure that control never reaches the end of a non-void function
 * @description Non-void functions that end without an explicit return can produce unpredictable
 *              results.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc37-c
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p9
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.nonvoidfunctiondoesnotreturn.NonVoidFunctionDoesNotReturn

class ControlFlowReachesTheEndOfANonVoidFunctionQuery extends NonVoidFunctionDoesNotReturnSharedQuery
{
  ControlFlowReachesTheEndOfANonVoidFunctionQuery() {
    this = MiscPackage::controlFlowReachesTheEndOfANonVoidFunctionQuery()
  }
}

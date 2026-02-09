/**
 * @id cpp/cert/wrap-functions-that-can-spuriously-wake-up-in-loop
 * @name CON54-CPP: Wrap functions that can spuriously wake up in a loop
 * @description Not wrapping functions that can wake up spuriously in a conditioned loop can result
 *              race conditions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con54-cpp
 *       correctness
 *       concurrency
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.wrapspuriousfunctioninloop.WrapSpuriousFunctionInLoop

class WrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery extends WrapSpuriousFunctionInLoopSharedQuery {
  WrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery() {
    this = ConcurrencyPackage::wrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery()
  }
}

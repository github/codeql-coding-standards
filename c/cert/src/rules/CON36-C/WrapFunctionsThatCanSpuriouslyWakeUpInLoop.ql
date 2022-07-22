/**
 * @id c/cert/wrap-functions-that-can-spuriously-wake-up-in-loop
 * @name CON36-C: Wrap functions that can spuriously wake up in a loop
 * @description Not wrapping functions that can wake up spuriously in a conditioned loop can result
 *              race conditions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con36-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.wrapspuriousfunctioninloop.WrapSpuriousFunctionInLoop

class WrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery extends WrapSpuriousFunctionInLoopSharedQuery {
  WrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery() {
    this = Concurrency2Package::wrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery()
  }
}

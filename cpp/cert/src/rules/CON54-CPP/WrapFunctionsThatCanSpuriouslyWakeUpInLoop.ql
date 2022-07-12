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
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Concurrency

from ConditionalWait cw
where
  not isExcluded(cw, ConcurrencyPackage::wrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery()) and
  not cw.getEnclosingStmt().getParentStmt*() instanceof Loop
select cw, "Use of a function that may wake up spuriously without a controlling loop."

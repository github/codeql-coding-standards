/**
 * @id c/cert/call-only-async-safe-functions-within-signal-handlers
 * @name SIG30-C: Call only asynchronous-safe functions within signal handlers
 * @description Call only asynchronous-safe functions within signal handlers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/sig30-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, SignalHandlersPackage::callOnlyAsyncSafeFunctionsWithinSignalHandlersQuery()) and
select

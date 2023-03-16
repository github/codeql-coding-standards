/**
 * @id c/cert/do-not-call-signal-from-interruptible-signal-handlers
 * @name SIG34-C: Do not call signal() from within interruptible signal handlers
 * @description Do not call signal() from within interruptible signal handlers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/sig34-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, SignalHandlersPackage::doNotCallSignalFromInterruptibleSignalHandlersQuery()) and
select

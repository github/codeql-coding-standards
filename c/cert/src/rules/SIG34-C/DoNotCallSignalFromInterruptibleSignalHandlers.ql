/**
 * @id c/cert/do-not-call-signal-from-interruptible-signal-handlers
 * @name SIG34-C: Do not call signal() from within interruptible signal handlers
 * @description Do not call signal() from within interruptible signal handlers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/sig34-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Signal

from FunctionCall signal
where
  not isExcluded(signal,
    SignalHandlersPackage::doNotCallSignalFromInterruptibleSignalHandlersQuery()) and
  signal = any(SignalHandler handler).getReassertingCall()
select signal,
  "Reasserting handler bindings introduces a race condition on nonpersistent platforms and is redundant otherwise."

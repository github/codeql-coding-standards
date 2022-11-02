/**
 * @id c/cert/do-not-call-system
 * @name ENV33-C: Do not call 'system'
 * @description Use of the 'system' function may result in exploitable vulnerabilities.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/env33-c
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.security.CommandExecution

from FunctionCall call, SystemFunction target
where
  not isExcluded(call, BannedPackage::doNotCallSystemQuery()) and
  call.getTarget() = target and
  // Exclude calls to `system` with a `NULL` pointer, because it is allowed to determine the presence of a command processor.
  (target.getName() = "system" implies not call.getAnArgument().(Literal).getValue() = "0")
select call, "Call to banned function $@.", target, target.getName()

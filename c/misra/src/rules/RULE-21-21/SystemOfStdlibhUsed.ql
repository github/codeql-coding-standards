/**
 * @id c/misra/system-of-stdlibh-used
 * @name RULE-21-21: The Standard Library function system of 'stdlib.h' shall not be used
 * @description They use of the 'system()' function from 'stdlib.h' may result in exploitable
 *              vulnerabilities.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-21
 *       security
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from FunctionCall call, Function target
where
  not isExcluded(call, BannedPackage::systemOfStdlibhUsedQuery()) and
  call.getTarget() = target and
  target.hasGlobalOrStdName("system")
select call, "Call to banned function " + target.getName() + "."

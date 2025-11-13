/**
 * @id c/misra/call-to-banned-random-function
 * @name RULE-21-24: The random number generator functions of <stdlib.h> shall not be used
 * @description The standard functions rand() and srand() will not give high quality random results
 *              in all implementations and are therefore banned.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-21-24
 *       security
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 *       coding-standards/baseline/safety
 */

import cpp
import codingstandards.c.misra

from FunctionCall call, string name
where
  not isExcluded(call, Banned2Package::callToBannedRandomFunctionQuery()) and
  name = ["rand", "srand"] and
  call.getTarget().hasGlobalOrStdName(name)
select call, "Call to banned random number generation function '" + name + "'."

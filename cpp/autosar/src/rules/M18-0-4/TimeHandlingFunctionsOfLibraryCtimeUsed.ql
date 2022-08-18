/**
 * @id cpp/autosar/time-handling-functions-of-library-ctime-used
 * @name M18-0-4: The time handling functions of library <ctime> shall not be used
 * @description Time handling functions in the <ctime> library shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m18-0-4
 *       correctness
 *       security
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate isBannedCTimeFunctionCall(FunctionCall fc) {
  fc.getTarget()
      .hasGlobalOrStdName([
          "clock", "difftime", "mktime", "time", "asctime", "ctime", "gmtime", "localtime",
          "strftime"
        ])
}

from FunctionCall fc
where
  not isExcluded(fc, BannedFunctionsPackage::timeHandlingFunctionsOfLibraryCtimeUsedQuery()) and
  isBannedCTimeFunctionCall(fc)
select fc, "Use of banned function " + fc.getTarget().getName() + "."

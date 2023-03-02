/**
 * @id c/misra/standard-library-time-and-date-functions-used
 * @name RULE-21-10: The Standard Library time and date functions shall not be used
 * @description The use of date and time functions may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-10
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Function f, FunctionCall fc
where
  not isExcluded(fc, BannedPackage::standardLibraryTimeAndDateFunctionsUsedQuery()) and
  (
    fc.getTarget() = f and
    (
      f.getFile().getBaseName() = "time.h"
      or
      f.getName() = "wcsftime" and
      f.getFile().getBaseName() = "wchar.h"
    )
  )
select fc, "Call to banned function " + f.getName() + "."

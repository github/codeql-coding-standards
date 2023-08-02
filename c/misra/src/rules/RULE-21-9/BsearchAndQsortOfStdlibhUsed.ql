/**
 * @id c/misra/bsearch-and-qsort-of-stdlibh-used
 * @name RULE-21-9: The Standard Library functions 'bsearch' and 'qsort' of 'stdlib.h' shall not be used
 * @description The use of the Standard Library functions 'bsearch' and 'qsort' of 'stdlib.h' may
 *              result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-9
 *       security
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from FunctionCall fc, Function f
where
  not isExcluded(fc, BannedPackage::bsearchAndQsortOfStdlibhUsedQuery()) and
  f = fc.getTarget() and
  f.getName() = ["qsort", "bsearch"] and
  f.getFile().getBaseName() = "stdlib.h"
select fc, "Call to banned function " + f.getName() + "."

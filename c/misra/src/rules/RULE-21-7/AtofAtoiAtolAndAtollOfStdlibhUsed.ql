/**
 * @id c/misra/atof-atoi-atol-and-atoll-of-stdlibh-used
 * @name RULE-21-7: The Standard Library functions 'atof', 'atoi', 'atol' and 'atoll' of 'stdlib.h' shall not be used
 * @description The use of Standard Library functions 'atof', 'atoi', 'atol' and 'atoll' of
 *              'stdlib.h' may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-7
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

private string atoi() { result = ["atof", "atoi", "atol", "atoll"] }

from FunctionCall fc, Function f
where
  not isExcluded(fc, BannedPackage::atofAtoiAtolAndAtollOfStdlibhUsedQuery()) and
  f = fc.getTarget() and
  f.getName() = atoi() and
  f.getFile().getBaseName() = "stdlib.h"
select fc, "Call to banned function " + f.getName() + "."

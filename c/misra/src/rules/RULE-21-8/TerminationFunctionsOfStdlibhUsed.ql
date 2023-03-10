/**
 * @id c/misra/termination-functions-of-stdlibh-used
 * @name RULE-21-8: The Standard Library termination functions of stdlib.h shall not be used
 * @description The use of the Standard Library functions 'abort', 'exit' and 'system' of 'stdlib.h'
 *              may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-8
 *       correctness
 *       security
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

class BannedFunction extends Function {
  BannedFunction() {
    this.getName() = ["abort", "exit", "system"] and
    this.getFile().getBaseName() = "stdlib.h"
  }
}

from FunctionCall fc, BannedFunction f
where
  not isExcluded(fc, BannedPackage::terminationFunctionsOfStdlibhUsedQuery()) and
  f = fc.getTarget()
select fc, "Call to banned function " + f.getName() + "."

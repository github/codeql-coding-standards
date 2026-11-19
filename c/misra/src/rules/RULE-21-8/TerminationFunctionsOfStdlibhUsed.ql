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
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/c/2025
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.commons.Assertions

from FunctionCall fc, string message
where
  not isExcluded(fc, BannedPackage::terminationFunctionsOfStdlibhUsedQuery()) and
  exists(Function f | f = fc.getTarget() |
    if f.hasGlobalOrStdName(["abort", "exit", "system"]) and f.getFile().getBaseName() = "stdlib.h"
    then message = "Call to banned function " + f.getName() + "."
    else
      exists(Options options, LibcAssert assertion |
        options.exits(f) and
        assertion.getAnExpandedElement() = fc and
        message = "Enabled assertion calls non-returning function '" + f.getName() + "'."
      )
  )
select fc, message

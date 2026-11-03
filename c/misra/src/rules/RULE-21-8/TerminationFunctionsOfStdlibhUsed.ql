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

/** A Standard Library termination function prohibited by this rule. */
class BannedFunction extends Function {
  BannedFunction() {
    this.getName() = ["abort", "exit", "system"] and
    this.getFile().getBaseName() = "stdlib.h"
  }
}

from FunctionCall fc, Function f, string message
where
  not isExcluded(fc, BannedPackage::terminationFunctionsOfStdlibhUsedQuery()) and
  f = fc.getTarget() and
  (
    f instanceof BannedFunction
    or
    any(Options options).exits(f) and
    exists(LibcAssert assertion | assertion.getAnExpandedElement() = fc)
  ) and
  (
    if f instanceof BannedFunction
    then message = "Call to banned function " + f.getName() + "."
    else message = "Enabled assertion calls non-returning function '" + f.getName() + "'."
  )
select fc, message

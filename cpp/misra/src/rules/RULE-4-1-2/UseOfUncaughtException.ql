/**
 * @id cpp/misra/use-of-uncaught-exception
 * @name RULE-4-1-2: Function uncaught_exception is a deprecated language feature should not be used
 * @description Deprecated language features such as uncaught_exception are only supported for
 *              backwards compatibility; these are considered bad practice, or have been superseded
 *              by better alternatives.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-4-1-2
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from FunctionCall fc
where
  not isExcluded(fc, Toolchain3Package::useOfUncaughtExceptionQuery()) and
  fc.getTarget().hasQualifiedName("std", "uncaught_exception")
select fc, "Call to deprecated function 'std::uncaught_exception'."

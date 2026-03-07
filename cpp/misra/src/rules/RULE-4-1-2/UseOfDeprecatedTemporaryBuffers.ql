/**
 * @id cpp/misra/use-of-deprecated-temporary-buffers
 * @name RULE-4-1-2: Temporary buffers are deprecated language features and should not be used
 * @description Deprecated language features such as temporary buffers are only supported for
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
  not isExcluded(fc, Toolchain3Package::useOfDeprecatedTemporaryBuffersQuery()) and
  fc.getTarget().hasQualifiedName("std", ["get_temporary_buffer", "return_temporary_buffer"])
select fc, "Call to deprecated function 'std::" + fc.getTarget().getName() + "'."

/**
 * @id cpp/misra/use-of-deprecated-str-stream-class
 * @name RULE-4-1-2: The char* stream classes strstreambuf, istreamstr, ostramstr, and strstream are deprecated and should not be used
 * @description Deprecated language features such as the char* stream classes are only supported for
 *              backwards compatibility; these are considered bad practice, or have been superceded
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

from
where
  not isExcluded(x, Toolchain3Package::useOfDeprecatedStrStreamClassQuery()) and
select

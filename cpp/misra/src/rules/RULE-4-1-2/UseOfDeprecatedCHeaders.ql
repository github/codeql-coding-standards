/**
 * @id cpp/misra/use-of-deprecated-c-headers
 * @name RULE-4-1-2: Use of <ccomplex>, <cstdalign>, and <cstdbool>, or <ctgmath> is deprecated and therefore these headers should not be used
 * @description These C standard library headers are only supported for backwards compatibility;
 *              these are considered bad practice, or have been superceded by better alternatives.
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

from Include include, string includeText
where
  not isExcluded(include, Toolchain3Package::useOfDeprecatedCHeadersQuery()) and
  includeText = include.getIncludeText() and
  includeText = "<c" + ["complex", "stdalign", "stdbool", "tgmath"] + ">"
select include, "Inclusion of deprecated C header '" + includeText + "'."

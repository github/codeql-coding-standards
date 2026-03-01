/**
 * @id cpp/misra/use-of-deprecated-unary-or-binary-negate
 * @name RULE-4-1-2: Typedefs unary_negate and binary_negate are deprecated language features and should not be used
 * @description Deprecated language features such as unary_negate and binary_negate are only
 *              supported for backwards compatibility; these are considered bad practice, or have
 *              been superceded by better alternatives.
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
  not isExcluded(x, Toolchain3Package::useOfDeprecatedUnaryOrBinaryNegateQuery()) and
select

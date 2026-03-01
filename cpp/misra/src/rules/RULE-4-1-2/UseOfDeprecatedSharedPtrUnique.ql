/**
 * @id cpp/misra/use-of-deprecated-shared-ptr-unique
 * @name RULE-4-1-2: Observer member shared_ptr::unique is a deprecated language feature and should not be used
 * @description Deprecated language features such as shared_ptr::unique are only supported for
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
  not isExcluded(x, Toolchain3Package::useOfDeprecatedSharedPtrUniqueQuery()) and
select

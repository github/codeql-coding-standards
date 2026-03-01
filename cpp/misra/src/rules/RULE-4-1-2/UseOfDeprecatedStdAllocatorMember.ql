/**
 * @id cpp/misra/use-of-deprecated-std-allocator-member
 * @name RULE-4-1-2: Certain members of std::allocator are deprecated language features and should not be used
 * @description Deprecated language features such as certain members of std::allocator are only
 *              supported for backwards compatibility; these are considered bad practice, or have
 *              been superceded by better alternatives.
 * @kind problem
 * @precision very_high
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
  not isExcluded(x, Toolchain3Package::useOfDeprecatedStdAllocatorMemberQuery()) and
select

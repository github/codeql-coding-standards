/**
 * @id cpp/misra/use-of-deprecated-function-binder-typedef-member-audit
 * @name RULE-4-1-2: Certain members of function binder typedefs are deprecated language features and should not be used
 * @description Deprecated language features such as certain function binder typedef members are
 *              only supported for backwards compatibility; these are considered bad practice, or
 *              have been superceded by better alternatives.
 * @kind problem
 * @precision low
 * @problem.severity warning
 * @tags external/misra/id/rule-4-1-2
 *       scope/single-translation-unit
 *       maintainability
 *       audit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, Toolchain3Package::useOfDeprecatedFunctionBinderTypedefMemberAuditQuery()) and
select

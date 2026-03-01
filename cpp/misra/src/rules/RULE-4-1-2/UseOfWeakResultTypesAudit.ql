/**
 * @id cpp/misra/use-of-weak-result-types-audit
 * @name RULE-4-1-2: Weak result types are a deprecated language feature should not be used
 * @description Deprecated language features such as weak result types are only supported for
 *              backwards compatibility; these are considered bad practice, or have been superceded
 *              by better alternatives.
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
  not isExcluded(x, Toolchain3Package::useOfWeakResultTypesAuditQuery()) and
select

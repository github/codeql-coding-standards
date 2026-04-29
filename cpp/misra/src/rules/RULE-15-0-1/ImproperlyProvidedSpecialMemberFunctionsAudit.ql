/**
 * @id cpp/misra/improperly-provided-special-member-functions-audit
 * @name RULE-15-0-1: Special member functions shall be provided appropriately, Audit
 * @description Audit: incorrect provision of special member functions can lead to unexpected or
 *              undefined behavior when objects of the class are copied, moved, or destroyed.
 * @kind problem
 * @precision low
 * @problem.severity warning
 * @tags external/misra/id/rule-15-0-1
 *       scope/single-translation-unit
 *       correctness
 *       audit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, Classes3Package::improperlyProvidedSpecialMemberFunctionsAuditQuery()) and
select

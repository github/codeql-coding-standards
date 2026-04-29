/**
 * @id cpp/misra/improperly-provided-special-member-functions
 * @name RULE-15-0-1: Special member functions shall be provided appropriately
 * @description Incorrect provision of special member functions can lead to unexpected or undefined
 *              behavior when objects of the class are copied, moved, or destroyed.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/misra/id/rule-15-0-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, Classes3Package::improperlyProvidedSpecialMemberFunctionsQuery()) and
select

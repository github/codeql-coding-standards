/**
 * @id c/misra/flexible-array-members-declared
 * @name RULE-18-7: Flexible array members shall not be declared
 * @description The use of flexible array members can lead to unexpected program behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-7
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Variable

from FlexibleArrayMember f
where not isExcluded(f, Declarations6Package::flexibleArrayMembersDeclaredQuery())
select f, "Flexible array member declared."

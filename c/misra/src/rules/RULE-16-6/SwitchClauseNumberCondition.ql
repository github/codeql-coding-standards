/**
 * @id c/misra/switch-clause-number-condition
 * @name RULE-16-6: Every switch statement shall have at least two switch-clauses
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-16-6
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, Statements2Package::switchClauseNumberConditionQuery()) and
select

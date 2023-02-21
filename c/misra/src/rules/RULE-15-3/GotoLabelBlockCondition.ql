/**
 * @id c/misra/goto-label-block-condition
 * @name RULE-15-3: Any label referenced by a goto statement shall be declared in the same block, or in any block
 * @description Any label referenced by a goto statement shall be declared in the same block, or in
 *              any block enclosing the goto statement
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-15-3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, Statements2Package::gotoLabelBlockConditionQuery()) and
select

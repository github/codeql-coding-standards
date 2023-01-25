/**
 * @id c/misra/const-expr-eval-causes-unsigned-int-wraparound
 * @name RULE-12-4: Evaluation of constant expressions should not lead to unsigned integer wrap-around
 * @description TODO.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-4
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::constExprEvalCausesUnsignedIntWraparoundQuery()) and
select

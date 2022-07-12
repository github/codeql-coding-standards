/**
 * @id cpp/autosar/expression-should-not-rely-on-order-of-evaluation
 * @name A5-0-1: The value of an expression does not rely on the order of evaluation
 * @description The value of an expression shall be the same under any order of evaluation that the
 *              standard permits.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a5-0-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects
import codingstandards.cpp.Ordering
import codingstandards.cpp.orderofevaluation.VariableAccessOrdering

from
  VariableAccessInFullExpressionOrdering config, FullExpr e, VariableEffect ve, VariableAccess va1,
  VariableAccess va2, Variable v
where
  not isExcluded(e, OrderOfEvaluationPackage::expressionShouldNotRelyOnOrderOfEvaluationQuery()) and
  e = va1.(ConstituentExpr).getFullExpr() and
  va1 = ve.getAnAccess() and
  config.isUnsequenced(va1, va2) and
  v = va1.getTarget()
select e,
  "The evaluation is depended on the order of evaluation of $@, that is modified by $@ and $@, that both access $@.",
  va1, "sub-expression", ve, "expression", va2, "sub-expression", v, v.getName()

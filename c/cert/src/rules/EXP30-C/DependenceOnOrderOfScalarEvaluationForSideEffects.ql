/**
 * @id c/cert/dependence-on-order-of-scalar-evaluation-for-side-effects
 * @name EXP30-C: Do not depend on the order of scalar object evaluation for side effects
 * @description Depending on the order of evaluation for side effects for evaluation of scalar
 *              objects that are unsequenced results in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/exp30-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.SideEffect
import codingstandards.c.Ordering
import codingstandards.c.orderofevaluation.VariableAccessOrdering

from
  VariableAccessInFullExpressionOrdering config, FullExpr e, ScalarVariable v, VariableEffect ve,
  VariableAccess va1, VariableAccess va2
where
  not isExcluded(e, SideEffects1Package::dependenceOnOrderOfScalarEvaluationForSideEffectsQuery()) and
  e = va1.(ConstituentExpr).getFullExpr() and
  va1 = ve.getAnAccess() and
  config.isUnsequenced(va1, va2) and
  v = va1.getTarget()
select e, "Scalar object referenced by $@ has a $@ that is unsequenced in relative to another $@.",
  v, v.getName(), ve, "side-effect", va2, "side-effect or value computation"

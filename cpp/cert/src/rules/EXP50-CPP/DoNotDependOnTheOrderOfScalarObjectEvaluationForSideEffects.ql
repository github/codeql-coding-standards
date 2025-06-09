/**
 * @id cpp/cert/do-not-depend-on-the-order-of-scalar-object-evaluation-for-side-effects
 * @name EXP50-CPP: Do not depend on the order of scalar object evaluation for side effects
 * @description Depending on the order of evaluation for side effects for evaluation of scalar
 *              objects that are unsequenced results in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/exp50-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p8
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.SideEffect
import codingstandards.cpp.Ordering
import codingstandards.cpp.orderofevaluation.VariableAccessOrdering
import codingstandards.cpp.Expr
import codingstandards.cpp.Variable

from
  VariableAccessInFullExpressionOrdering config, FullExpr e, ScalarVariable v, VariableEffect ve,
  VariableAccess va1, VariableAccess va2
where
  not isExcluded(e,
    SideEffects1Package::doNotDependOnTheOrderOfScalarObjectEvaluationForSideEffectsQuery()) and
  e = va1.(ConstituentExpr).getFullExpr() and
  va1 = ve.getAnAccess() and
  config.isUnsequenced(va1, va2) and
  v = va1.getTarget()
select e, "Scalar object referenced by $@ has a $@ that is unsequenced in relative to another $@.",
  v, v.getName(), ve, "side-effect", va2, "side-effect or value computation"

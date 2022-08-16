/**
 * @id c/misra/side-effect-and-crement-in-full-expression
 * @name RULE-13-3: A full expression containing an increment (++) or decrement (--) operator should have no other
 * @description A full expression containing an increment (++) or decrement (--) operator should
 *              have no other potential side effects other than that caused by the increment or
 *              decrement operator.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-13-3
 *       readability
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Expr
import codingstandards.c.SideEffects

from FullExpr e, SideEffect se, CrementOperation op
where
  not isExcluded(e, SideEffects2Package::sideEffectAndCrementInFullExpressionQuery()) and
  e.getAChild+() = op and
  se = getASideEffect(e) and
  not se instanceof CrementOperation
select e, "The full expression contains the $@ and the $@.", op, op.getOperator(), se, "side effect"

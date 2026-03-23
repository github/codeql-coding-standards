/**
 * @id cpp/misra/assert-macro-used-with-a-constant-expression
 * @name RULE-22-3-1: The assert macro shall not be used with a constant-expression
 * @description Compile time checking of constant expressions via static_assert is preferred to
 *              potentially disabled runtime checking via the assert macro.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-3-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.standardlibrary.Assert

predicate isConstantExpression(Expr e) { exists(e.getValue()) }

from AssertInvocation assertion, Expr assertedExpr
where
  not isExcluded(assertion, Preconditions3Package::assertMacroUsedWithAConstantExpressionQuery()) and
  not assertion.isAssertFalse() and
  assertedExpr = assertion.getAssertCondition() and
  isConstantExpression(assertedExpr)
select assertion, "Call to 'assert' macro with constant expression value $@.", assertedExpr,
  assertedExpr.getValue().toString()

/**
 * @id c/cert/do-not-compare-function-pointers-to-constant-values
 * @name EXP16-C: Do not compare function pointers to constant values
 * @description Comparing function pointers to a constant value is not reliable and likely indicates
 *              a programmer error.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp16-c
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/recommendation
 */

import cpp
import semmle.code.cpp.controlflow.IRGuards
import codingstandards.c.cert
import codingstandards.cpp.types.FunctionType
import codingstandards.cpp.exprs.FunctionExprs
import codingstandards.cpp.exprs.Guards

final class FinalElement = Element;

abstract class EffectivelyComparison extends FinalElement {
  abstract string getExplanation();

  abstract FunctionExpr getFunctionExpr();
}

final class FinalComparisonOperation = ComparisonOperation;

class ExplicitComparison extends EffectivelyComparison, FinalComparisonOperation {
  Expr constantExpr;
  FunctionExpr funcExpr;

  ExplicitComparison() {
    funcExpr = getAnOperand() and
    constantExpr = getAnOperand() and
    exists(constantExpr.getValue()) and
    not funcExpr = constantExpr and
    not constantExpr.getExplicitlyConverted().getUnderlyingType() =
      funcExpr.getExplicitlyConverted().getUnderlyingType()
  }

  override string getExplanation() { result = "$@ compared to constant value." }

  override FunctionExpr getFunctionExpr() { result = funcExpr }
}

class ImplicitComparison extends EffectivelyComparison, GuardCondition {
  ImplicitComparison() {
    this instanceof FunctionExpr and
    not getParent() instanceof ComparisonOperation
  }

  override string getExplanation() { result = "$@ undergoes implicit constant comparison." }

  override FunctionExpr getFunctionExpr() { result = this }
}

from EffectivelyComparison comparison, FunctionExpr funcExpr, Element function, string funcName
where
  not isExcluded(comparison,
    Expressions2Package::doNotCompareFunctionPointersToConstantValuesQuery()) and
  funcExpr = comparison.getFunctionExpr() and
  not exists(NullFunctionCallGuard nullGuard | nullGuard.getFunctionExpr() = funcExpr) and
  function = funcExpr.getFunction() and
  funcName = funcExpr.describe()
select comparison, comparison.getExplanation(), function, funcName

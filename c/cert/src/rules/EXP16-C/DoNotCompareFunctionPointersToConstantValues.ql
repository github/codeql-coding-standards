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
 *       external/cert/obligation/recommendation
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.types.FunctionType
import semmle.code.cpp.controlflow.IRGuards

class FunctionExpr extends Expr {
  Element function;
  string funcName;

  FunctionExpr() {
    function = this.(FunctionAccess).getTarget() and
    funcName = "Function " + function.(Function).getName()
    or
    this.(VariableAccess).getUnderlyingType() instanceof FunctionType and
    function = this and
    funcName = "Function pointer variable " + this.(VariableAccess).getTarget().getName()
    or
    this.getUnderlyingType() instanceof FunctionType and
    not this instanceof FunctionAccess and
    not this instanceof VariableAccess and
    function = this and
    funcName = "Expression with function pointer type"
  }

  Element getFunction() { result = function }

  string getFuncName() { result = funcName }
}

abstract class EffectivelyComparison extends Element {
  abstract string getExplanation();

  abstract FunctionExpr getFunctionExpr();
}

class ExplicitComparison extends EffectivelyComparison, ComparisonOperation {
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
  function = funcExpr.getFunction() and
  funcName = funcExpr.getFuncName()
select comparison, comparison.getExplanation(), function, funcName

/**
 * @id c/cert/do-not-pass-aliased-pointer-to-restrict-qualified-param
 * @name EXP43-C: Do not pass aliased pointers to restrict-qualified parameters
 * @description Passing an aliased pointer to a restrict-qualified parameter is undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/exp43-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Pointers
import codingstandards.c.Variable
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.pointsto.PointsTo
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

/**
 * A function that has a parameter with a restrict-qualified pointer type.
 */
class FunctionWithRestrictParameters extends Function {
  Parameter restrictPtrParam;

  FunctionWithRestrictParameters() {
    restrictPtrParam = this.getAParameter() and
    restrictPtrParam.getUnspecifiedType() instanceof PointerOrArrayType and
    restrictPtrParam.getType().hasSpecifier("restrict")
  }

  Parameter getARestrictPtrParam() { result = restrictPtrParam }
}

/**
 * A call to a function that has a parameter with a restrict-qualified pointer type.
 */
class CallToFunctionWithRestrictParameters extends FunctionCall {
  CallToFunctionWithRestrictParameters() {
    this.getTarget() instanceof FunctionWithRestrictParameters
  }

  Expr getARestrictPtrArg() {
    result =
      this.getArgument(this.getTarget()
            .(FunctionWithRestrictParameters)
            .getARestrictPtrParam()
            .getIndex())
  }

  Expr getAPtrArg() {
    result = this.getAnArgument() and
    pointerValue(result)
  }

  Expr getAPossibleSizeArg() {
    exists(Parameter param |
      param = this.getTarget().(FunctionWithRestrictParameters).getAParameter() and
      param.getUnderlyingType() instanceof IntegralType and
      // exclude __builtin_object_size
      not result.(FunctionCall).getTarget() instanceof BuiltInFunction and
      result = this.getArgument(param.getIndex())
    )
  }
}

/**
 * A `PointsToExpr` that is an argument of a pointer-type in a `CallToFunctionWithRestrictParameters`
 */
class CallToFunctionWithRestrictParametersArgExpr extends Expr {
  CallToFunctionWithRestrictParametersArgExpr() {
    this = any(CallToFunctionWithRestrictParameters call).getAPtrArg()
  }
}

int getStatedValue(Expr e) {
  // `upperBound(e)` defaults to `exprMaxVal(e)` when `e` isn't analyzable. So to get a meaningful
  // result in this case we pick the minimum value obtainable from dataflow and range analysis.
  result =
    upperBound(e)
        .minimum(min(Expr source | DataFlow::localExprFlow(source, e) | source.getValue().toInt()))
}

int getPointerArithmeticOperandStatedValue(CallToFunctionWithRestrictParametersArgExpr expr) {
  result = getStatedValue(expr.(PointerArithmeticExpr).getOperand())
  or
  // edge-case: &(array[index]) expressions
  result = getStatedValue(expr.(AddressOfExpr).getOperand().(PointerArithmeticExpr).getOperand())
  or
  // fall-back if `expr` is not a pointer arithmetic expression
  not expr instanceof PointerArithmeticExpr and
  not expr.(AddressOfExpr).getOperand() instanceof PointerArithmeticExpr and
  result = 0
}

class PointerValueToRestrictArgConfig extends DataFlow::Configuration {
  PointerValueToRestrictArgConfig() { this = "PointerValueToRestrictArgConfig" }

  override predicate isSource(DataFlow::Node source) { pointerValue(source.asExpr()) }

  override predicate isSink(DataFlow::Node sink) {
    exists(CallToFunctionWithRestrictParameters call |
      sink.asExpr() = call.getAPtrArg().getAChild*()
    )
  }
}

from
  CallToFunctionWithRestrictParameters call, CallToFunctionWithRestrictParametersArgExpr arg1,
  CallToFunctionWithRestrictParametersArgExpr arg2, int argOffset1, int argOffset2
where
  not isExcluded(call, Pointers3Package::doNotPassAliasedPointerToRestrictQualifiedParamQuery()) and
  arg1 = call.getARestrictPtrArg() and
  arg2 = call.getAPtrArg() and
  not arg1 = arg2 and
  exists(PointerValueToRestrictArgConfig config, Expr source1, Expr source2 |
    config.hasFlow(DataFlow::exprNode(source1), DataFlow::exprNode(arg1.getAChild*())) and
    (
      // one pointer value flows to both args
      config.hasFlow(DataFlow::exprNode(source1), DataFlow::exprNode(arg2.getAChild*()))
      or
      // there are two separate values that flow from an AddressOfExpr of the same target
      getAddressOfExprTargetBase(source1) = getAddressOfExprTargetBase(source2) and
      config.hasFlow(DataFlow::exprNode(source2), DataFlow::exprNode(arg2.getAChild*()))
    )
  ) and
  // get the offset of the pointer arithmetic operand (or '0' if there is none)
  argOffset1 = getPointerArithmeticOperandStatedValue(arg1) and
  argOffset2 = getPointerArithmeticOperandStatedValue(arg2) and
  (
    // case 1: the pointer args are the same.
    // (definite aliasing)
    argOffset1 = argOffset2
    or
    // case 2: the pointer args are different, a size arg exists,
    // and the size arg is greater than the difference between the offsets.
    // (potential aliasing)
    exists(Expr sizeArg |
      sizeArg = call.getAPossibleSizeArg() and
      getStatedValue(sizeArg) > (argOffset1 - argOffset2).abs()
    )
    or
    // case 3: the pointer args are different, and a size arg does not exist
    // (potential aliasing)
    not exists(call.getAPossibleSizeArg())
  )
select call,
  "Call to '" + call.getTarget().getName() +
    "' passes an aliased pointer to a restrict-qualified parameter."

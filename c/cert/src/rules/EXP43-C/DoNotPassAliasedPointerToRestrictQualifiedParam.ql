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
    restrictPtrParam.getUnspecifiedType() instanceof PointerOrArrayType and
    (
      restrictPtrParam.getType().hasSpecifier(["restrict"]) and
      restrictPtrParam = this.getAParameter()
      or
      this.hasGlobalName(["strcpy", "strncpy", "strcat", "strncat", "memcpy"]) and
      restrictPtrParam = this.getParameter([0, 1])
      or
      this.hasGlobalName(["strcpy_s", "strncpy_s", "strcat_s", "strncat_s", "memcpy_s"]) and
      restrictPtrParam = this.getParameter([0, 2])
      or
      this.hasGlobalName(["strtok_s"]) and
      restrictPtrParam = this.getAParameter()
      or
      this.hasGlobalName(["printf", "printf_s", "scanf", "scanf_s"]) and
      restrictPtrParam = this.getParameter(0)
      or
      this.hasGlobalName(["sprintf", "sprintf_s", "snprintf", "snprintf_s"]) and
      restrictPtrParam = this.getParameter(3)
    )
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

  Expr getAPtrArg(int index) {
    result = this.getArgument(index) and
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
  int paramIndex;

  CallToFunctionWithRestrictParametersArgExpr() {
    this = any(CallToFunctionWithRestrictParameters call).getAPtrArg(paramIndex)
  }

  int getParamIndex() { result = paramIndex }
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
      sink.asExpr() = call.getAPtrArg(_).getAChild*()
    )
  }

  override predicate isBarrierIn(DataFlow::Node node) {
    exists(AddressOfExpr a | node.asExpr() = a.getOperand().getAChild*())
  }
}

from
  PointerValueToRestrictArgConfig config, CallToFunctionWithRestrictParameters call,
  CallToFunctionWithRestrictParametersArgExpr arg1,
  CallToFunctionWithRestrictParametersArgExpr arg2, int argOffset1, int argOffset2, Expr source1,
  Expr source2, string sourceMessage1, string sourceMessage2
where
  not isExcluded(call, Pointers3Package::doNotPassAliasedPointerToRestrictQualifiedParamQuery()) and
  arg1 = call.getARestrictPtrArg() and
  arg2 = call.getAPtrArg(_) and
  // enforce ordering to remove permutations if multiple restrict-qualified args exist
  (not arg2 = call.getARestrictPtrArg() or arg2.getParamIndex() > arg1.getParamIndex()) and
  (
    // check if two pointers address the same object
    config.hasFlow(DataFlow::exprNode(source1), DataFlow::exprNode(arg1.getAChild*())) and
    (
      // one pointer value flows to both args
      config.hasFlow(DataFlow::exprNode(source1), DataFlow::exprNode(arg2.getAChild*())) and
      sourceMessage1 = "$@" and
      sourceMessage2 = "source" and
      source1 = source2
      or
      // there are two separate values that flow from an AddressOfExpr of the same target
      getAddressOfExprTargetBase(source1) = getAddressOfExprTargetBase(source2) and
      config.hasFlow(DataFlow::exprNode(source2), DataFlow::exprNode(arg2.getAChild*())) and
      sourceMessage1 = "a pair of address-of expressions ($@, $@)" and
      sourceMessage2 = "addressof1" and
      not source1 = source2
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
  "Call to '" + call.getTarget().getName() + "' passes an $@ to a $@ (pointer value derived from " +
    sourceMessage1 + ".", arg2, "aliased pointer", arg1, "restrict-qualified parameter", source1,
  sourceMessage2, source2, "addressof2"

/**
 * @id c/cert/do-not-pass-alised-pointer-to-restrict-qualified-parameter
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
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.pointsto.PointsTo
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

/**
 * A type that is a pointer or array type.
 */
class PointerOrArrayType extends DerivedType {
  PointerOrArrayType() {
    this.stripTopLevelSpecifiers() instanceof PointerType or
    this.stripTopLevelSpecifiers() instanceof ArrayType
  }
}

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
class ArgPointsToExpr extends PointsToExpr {
  override predicate interesting() {
    any(CallToFunctionWithRestrictParameters call).getAnArgument() = this and
    pointerValue(this)
  }
}

int getStatedValue(Expr e) {
  // `upperBound(e)` defaults to `exprMaxVal(e)` when `e` isn't analyzable. So to get a meaningful
  // result in this case we pick the minimum value obtainable from dataflow and range analysis.
  result =
    upperBound(e)
        .minimum(min(Expr source | DataFlow::localExprFlow(source, e) | source.getValue().toInt()))
}

int getPointerArithmeticOperandStatedValue(ArgPointsToExpr expr) {
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

from
  CallToFunctionWithRestrictParameters call, ArgPointsToExpr arg1, ArgPointsToExpr arg2,
  int argOffset1, int argOffset2
where
  not isExcluded(call, Pointers3Package::doNotPassAlisedPointerToRestrictQualifiedParameterQuery()) and
  arg1 = call.getARestrictPtrArg() and
  arg2 = call.getAPtrArg() and
  // two arguments that point to the same object
  arg1 != arg2 and
  arg1.pointsTo() = arg2.pointsTo() and
  arg1.confidence() = 1.0 and
  arg2.confidence() = 1.0 and
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

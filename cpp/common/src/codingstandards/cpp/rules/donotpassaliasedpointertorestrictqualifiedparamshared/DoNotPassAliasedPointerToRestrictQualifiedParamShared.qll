/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.types.Pointers
import codingstandards.cpp.Variable
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

module PointerValueToRestrictArgConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { pointerValue(source.asExpr()) }

  predicate isSink(DataFlow::Node sink) {
    exists(CallToFunctionWithRestrictParameters call |
      sink.asExpr() = call.getAPtrArg(_).getAChild*()
    )
  }

  predicate isBarrierIn(DataFlow::Node node) {
    exists(AddressOfExpr a | node.asExpr() = a.getOperand().getAChild*())
  }
}

module PointerValueToRestrictArgFlow = DataFlow::Global<PointerValueToRestrictArgConfig>;

abstract class DoNotPassAliasedPointerToRestrictQualifiedParamSharedSharedQuery extends Query { }

Query getQuery() {
  result instanceof DoNotPassAliasedPointerToRestrictQualifiedParamSharedSharedQuery
}

query predicate problems(
  CallToFunctionWithRestrictParameters call, string message,
  CallToFunctionWithRestrictParametersArgExpr arg2, string arg2message,
  CallToFunctionWithRestrictParametersArgExpr arg1, string arg1message, Expr source1,
  string sourceMessage2, Expr source2, string lastMessage2
) {
  not isExcluded(call, getQuery()) and
  exists(int argOffset1, int argOffset2, string sourceMessage1 |
    arg1 = call.getARestrictPtrArg() and
    arg2 = call.getAPtrArg(_) and
    // enforce ordering to remove permutations if multiple restrict-qualified args exist
    (not arg2 = call.getARestrictPtrArg() or arg2.getParamIndex() > arg1.getParamIndex()) and
    (
      // check if two pointers address the same object
      PointerValueToRestrictArgFlow::flow(DataFlow::exprNode(source1),
        DataFlow::exprNode(arg1.getAChild*())) and
      (
        // one pointer value flows to both args
        PointerValueToRestrictArgFlow::flow(DataFlow::exprNode(source1),
          DataFlow::exprNode(arg2.getAChild*())) and
        sourceMessage1 = "$@" and
        sourceMessage2 = "source" and
        source1 = source2
        or
        // there are two separate values that flow from an AddressOfExpr of the same target
        getAddressOfExprTargetBase(source1) = getAddressOfExprTargetBase(source2) and
        PointerValueToRestrictArgFlow::flow(DataFlow::exprNode(source2),
          DataFlow::exprNode(arg2.getAChild*())) and
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
    ) and
    lastMessage2 = "addressof2" and
    arg2message = "aliased pointer" and
    arg1message = "restrict-qualified parameter" and
    message =
      "Call to '" + call.getTarget().getName() +
        "' passes an $@ to a $@ (pointer value derived from " + sourceMessage1 + "."
  )
}

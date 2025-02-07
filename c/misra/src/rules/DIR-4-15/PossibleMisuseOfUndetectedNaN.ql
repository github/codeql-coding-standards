/**
 * @id c/misra/possible-misuse-of-undetected-na-n
 * @name DIR-4-15: Evaluation of floating-point expressions shall not lead to the undetected generation of NaNs
 * @description Evaluation of floating-point expressions shall not lead to the undetected generation
 *              of NaNs.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/dir-4-15
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codeql.util.Boolean
import codingstandards.c.misra
import codingstandards.cpp.RestrictedRangeAnalysis
import codingstandards.cpp.FloatingPoint
import codingstandards.cpp.AlertReporting
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.dataflow.new.TaintTracking
import semmle.code.cpp.controlflow.Dominance

bindingset[name]
Function getMathVariants(string name) { result.hasGlobalOrStdName([name, name + "f", name + "l"]) }

predicate hasDomainError(FunctionCall fc, string description) {
  exists(Function functionWithDomainError | fc.getTarget() = functionWithDomainError |
    functionWithDomainError = [getMathVariants(["acos", "asin", "atanh"])] and
    not (
      RestrictedRangeAnalysis::upperBound(fc.getArgument(0)) <= 1.0 and
      RestrictedRangeAnalysis::lowerBound(fc.getArgument(0)) >= -1.0
    ) and
    description =
      "the argument has a range " + RestrictedRangeAnalysis::lowerBound(fc.getArgument(0)) + "..." +
        RestrictedRangeAnalysis::upperBound(fc.getArgument(0)) + " which is outside the domain of this function (-1.0...1.0)"
    or
    functionWithDomainError = getMathVariants(["atan2", "pow"]) and
    (
      exprMayEqualZero(fc.getArgument(0)) and
      exprMayEqualZero(fc.getArgument(1)) and
      description = "both arguments are equal to zero"
    )
    or
    functionWithDomainError = getMathVariants("pow") and
    (
      RestrictedRangeAnalysis::upperBound(fc.getArgument(0)) < 0.0 and
      RestrictedRangeAnalysis::upperBound(fc.getArgument(1)) < 0.0 and
      description = "both arguments are less than zero"
    )
    or
    functionWithDomainError = getMathVariants("acosh") and
    RestrictedRangeAnalysis::upperBound(fc.getArgument(0)) < 1.0 and
    description = "argument is less than 1"
    or
    //pole error is the same as domain for logb and tgamma (but not ilogb - no pole error exists)
    functionWithDomainError = getMathVariants(["ilogb", "logb", "tgamma"]) and
    exprMayEqualZero(fc.getArgument(0)) and
    description = "argument is equal to zero"
    or
    functionWithDomainError = getMathVariants(["log", "log10", "log2", "sqrt"]) and
    RestrictedRangeAnalysis::upperBound(fc.getArgument(0)) < 0.0 and
    description = "argument is negative"
    or
    functionWithDomainError = getMathVariants("log1p") and
    RestrictedRangeAnalysis::upperBound(fc.getArgument(0)) < -1.0 and
    description = "argument is less than 1"
    or
    functionWithDomainError = getMathVariants("fmod") and
    exprMayEqualZero(fc.getArgument(1)) and
    description = "y is 0"
  )
}

abstract class PotentiallyNaNExpr extends Expr {
  abstract string getReason();
}

class DomainErrorFunctionCall extends FunctionCall, PotentiallyNaNExpr {
  string reason;

  DomainErrorFunctionCall() {
    hasDomainError(this, reason)
  }

  override string getReason() { result = reason }
}

// IEEE 754-1985 Section 7.1 invalid operations
class InvalidOperationExpr extends BinaryOperation, PotentiallyNaNExpr {
  string reason;

  InvalidOperationExpr() {
    // Usual arithmetic conversions in both languages mean that if either operand is a floating
    // type, the other one is converted to a floating type as well.
    getAnOperand().getFullyConverted().getType() instanceof FloatingPointType and
    (
      // 7.1.1 propagates signaling NaNs, we rely on flow analysis and/or assume quiet NaNs, so we
      // intentionally do not cover this case.
      // 7.1.2: magnitude subtraction of infinities, such as +Inf + -Inf
      getOperator() = "+" and
      exists(Boolean sign |
        exprMayEqualInfinity(getLeftOperand(), sign) and
        exprMayEqualInfinity(getRightOperand(), sign.booleanNot())
      ) and
      reason = "from addition of infinity and negative infinity"
      or
      // 7.1.2 continued
      getOperator() = "-" and
      exists(Boolean sign |
        exprMayEqualInfinity(getLeftOperand(), sign) and
        exprMayEqualInfinity(getRightOperand(), sign)
      ) and
      reason = "from subtraction of an infinity from itself"
      or
      // 7.1.3: multiplication of zero by infinity
      getOperator() = "*" and
      exprMayEqualZero(getAnOperand()) and
      exprMayEqualInfinity(getAnOperand(), _) and
      reason = "from multiplication of zero by infinity"
      or
      // 7.1.4: Division of zero by zero, or infinity by infinity
      getOperator() = "/" and
      exprMayEqualZero(getLeftOperand()) and
      exprMayEqualZero(getRightOperand()) and
      reason = "from division of zero by zero"
      or
      // 7.1.4 continued
      getOperator() = "/" and
      exprMayEqualInfinity(getLeftOperand(), _) and
      exprMayEqualInfinity(getRightOperand(), _) and
      reason = "from division of infinity by infinity"
      or
      // 7.1.5: x % y where y is zero or x is infinite
      getOperator() = "%" and
      exprMayEqualInfinity(getLeftOperand(), _) and
      reason = "from modulus of infinity"
      or
      // 7.1.5 continued
      getOperator() = "%" and
      exprMayEqualZero(getRightOperand()) and
      reason = "from modulus by zero"
      // 7.1.6 handles the sqrt function, not covered here.
      // 7.1.7 declares exceptions during invalid conversions, which we catch as sinks in our flow
      // analysis.
      // 7.1.8 declares exceptions for unordered comparisons, which we catch as sinks in our flow
      // analysis.
    )
  }

  override string getReason() { result = reason }
}

module InvalidNaNUsage implements DataFlow::ConfigSig {
  /**
   * An expression which has non-NaN inputs and may produce a NaN output.
   */
  predicate isSource(DataFlow::Node node) {
    potentialSource(node) and
    not exists(DataFlow::Node prior |
      isAdditionalFlowStep(prior, node) and
      potentialSource(prior)
    )
  }

  /**
   * An expression which may produce a NaN output.
   */
  additional predicate potentialSource(DataFlow::Node node) {
    node.asExpr() instanceof PotentiallyNaNExpr
  }

  predicate isBarrierOut(DataFlow::Node node) {
    guardedNotFPClass(node.asExpr(), TNaN())
    or
    exists(Expr e |
      e.getType() instanceof IntegralType and
      e = node.asConvertedExpr()
    )
  }

  /**
   * Add an additional flow step to handle NaN propagation through floating point operations.
   */
  predicate isAdditionalFlowStep(DataFlow::Node source, DataFlow::Node sink) {
    exists(Operation o |
      o.getAnOperand() = source.asExpr() and
      o = sink.asExpr() and
      o.getType() instanceof FloatingPointType
    )
  }

  predicate isSink(DataFlow::Node node) {
    not guardedNotFPClass(node.asExpr(), TNaN()) and
    node instanceof InvalidNaNUsage
  }
}

class InvalidNaNUsage extends DataFlow::Node {
  string description;
  string nanDescription;

  InvalidNaNUsage() {
      // Case 1: NaNs shall not be compared, except to themselves
      exists(ComparisonOperation cmp |
        this.asExpr() = cmp.getAnOperand() and
        not hashCons(cmp.getLeftOperand()) = hashCons(cmp.getRightOperand()) and
        description = "Comparison involving a $@, which always evaluates to false." and
        nanDescription = "possibly NaN float value"
      )
      or
      // Case 2: NaNs and infinities shall not be cast to integers
      exists(Conversion c |
        this.asExpr() = c.getUnconverted() and
        c.getExpr().getType() instanceof FloatingPointType and
        c.getType() instanceof IntegralType and
        description = "$@ casted to integer." and
        nanDescription = "Possibly NaN float value"
      )
      //or
      //// Case 4: Functions shall not return NaNs or infinities
      //exists(ReturnStmt ret | node.asExpr() = ret.getExpr())
  }

  string getDescription() { result = description }

  string getNaNDescription() { result = nanDescription }
}

module InvalidNaNFlow = DataFlow::Global<InvalidNaNUsage>;

import InvalidNaNFlow::PathGraph

from
  Element elem, InvalidNaNFlow::PathNode source, InvalidNaNFlow::PathNode sink,
  InvalidNaNUsage usage, Expr sourceExpr, string sourceString, Element extra, string extraString
where
  not InvalidNaNFlow::PathGraph::edges(_, source, _, _) and
  not InvalidNaNFlow::PathGraph::edges(sink, _, _, _) and
  not sourceExpr.isFromTemplateInstantiation(_) and
  not usage.asExpr().isFromTemplateInstantiation(_) and
  elem = MacroUnwrapper<Expr>::unwrapElement(sink.getNode().asExpr()) and
  usage = sink.getNode() and
  sourceExpr = source.getNode().asExpr() and
    sourceString =
      " (" + source.getNode().asExpr().(PotentiallyNaNExpr).getReason() + ")" and
  InvalidNaNFlow::flow(source.getNode(), usage) and
  (
    if not sourceExpr.getEnclosingFunction() = usage.asExpr().getEnclosingFunction()
    then
    extraString = usage.getNaNDescription() + sourceString + " computed in function " + sourceExpr.getEnclosingFunction().getName()
    and extra = sourceExpr.getEnclosingFunction()
    else (
      extra = sourceExpr and
     extraString = usage.getNaNDescription() + sourceString
    )
  )
select elem, source, sink, usage.getDescription(), extra, extraString
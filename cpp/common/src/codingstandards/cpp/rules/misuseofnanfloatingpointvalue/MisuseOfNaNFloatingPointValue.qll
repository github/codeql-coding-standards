/**
 * Provides a library with a `problems` predicate for the following issue:
 * Possible mishandling of an undetected NaN value produced by a floating point
 * operation.
 */

import cpp
import codeql.util.Boolean
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.RestrictedRangeAnalysis
import codingstandards.cpp.FloatingPoint
import codingstandards.cpp.AlertReporting
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.dataflow.new.TaintTracking
import semmle.code.cpp.controlflow.Dominance

abstract class PotentiallyNaNExpr extends Expr {
  abstract string getReason();
}

class DomainErrorFunctionCall extends FunctionCall, PotentiallyNaNExpr {
  string reason;

  DomainErrorFunctionCall() { RestrictedDomainError::hasDomainError(this, reason) }

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
      exists(Expr zeroOp, Expr infinityOp |
        zeroOp = getAnOperand() and
        infinityOp = getAnOperand() and
        not zeroOp = infinityOp and
        exprMayEqualZero(zeroOp) and
        exprMayEqualInfinity(infinityOp, _)
      ) and
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

  InvalidNaNUsage() {
    // Case 1: NaNs shall not be compared, except to themselves
    exists(ComparisonOperation cmp |
      this.asExpr() = cmp.getAnOperand() and
      not hashCons(cmp.getLeftOperand()) = hashCons(cmp.getRightOperand()) and
      description = "comparison, which would always evaluate to false."
    )
    or
    // Case 2: NaNs and infinities shall not be cast to integers
    exists(Conversion c |
      this.asExpr() = c.getUnconverted() and
      c.getExpr().getType() instanceof FloatingPointType and
      c.getType() instanceof IntegralType and
      description = "a cast to integer."
    )
  }

  string getDescription() { result = description }
}

module InvalidNaNFlow = DataFlow::Global<InvalidNaNUsage>;

import InvalidNaNFlow::PathGraph

abstract class MisuseOfNaNFloatingPointValueSharedQuery extends Query { }

Query getQuery() { result instanceof MisuseOfNaNFloatingPointValueSharedQuery }

query predicate problems(
  Element elem, InvalidNaNFlow::PathNode source, InvalidNaNFlow::PathNode sink, string message,
  Expr sourceExpr, string sourceString, Function function, string functionName
) {
  not isExcluded(elem, getQuery()) and
  exists(InvalidNaNUsage usage, string computedInFunction |
    not InvalidNaNFlow::PathGraph::edges(_, source, _, _) and
    not InvalidNaNFlow::PathGraph::edges(sink, _, _, _) and
    not sourceExpr.isFromTemplateInstantiation(_) and
    not usage.asExpr().isFromTemplateInstantiation(_) and
    elem = MacroUnwrapper<Expr>::unwrapElement(sink.getNode().asExpr()) and
    usage = sink.getNode() and
    sourceExpr = source.getNode().asExpr() and
    sourceString = source.getNode().asExpr().(PotentiallyNaNExpr).getReason() and
    function = sourceExpr.getEnclosingFunction() and
    InvalidNaNFlow::flow(source.getNode(), usage) and
    (
      if not sourceExpr.getEnclosingFunction() = usage.asExpr().getEnclosingFunction()
      then computedInFunction = "computed in function $@ "
      else computedInFunction = ""
    ) and
    message = "Possible NaN value $@ " + computedInFunction + "flows to " + usage.getDescription() and
    functionName = function.getName()
  )
}

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

// IEEE 754-1985 Section 7.1 invalid operations
class InvalidOperationExpr extends BinaryOperation {
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
      reason = "possible addition of infinity and negative infinity"
      or
      // 7.1.2 continued
      getOperator() = "-" and
      exists(Boolean sign |
        exprMayEqualInfinity(getLeftOperand(), sign) and
        exprMayEqualInfinity(getRightOperand(), sign)
      ) and
      reason = "possible subtraction of an infinity from itself"
      or
      // 7.1.3: multiplication of zero by infinity
      getOperator() = "*" and
      exprMayEqualZero(getAnOperand()) and
      exprMayEqualInfinity(getAnOperand(), _) and
      reason = "possible multiplication of zero by infinity"
      or
      // 7.1.4: Division of zero by zero, or infinity by infinity
      getOperator() = "/" and
      exprMayEqualZero(getLeftOperand()) and
      exprMayEqualZero(getRightOperand()) and
      reason = "possible division of zero by zero"
      or
      // 7.1.4 continued
      getOperator() = "/" and
      exprMayEqualInfinity(getLeftOperand(), _) and
      exprMayEqualInfinity(getRightOperand(), _) and
      reason = "possible division of infinity by infinity"
      or
      // 7.1.5: x % y where y is zero or x is infinite
      getOperator() = "%" and
      exprMayEqualInfinity(getLeftOperand(), _) and
      reason = "possible modulus of infinity"
      or
      // 7.1.5 continued
      getOperator() = "%" and
      exprMayEqualZero(getRightOperand()) and
      reason = "possible modulus by zero"
      // 7.1.6 handles the sqrt function, not covered here.
      // 7.1.7 declares exceptions during invalid conversions, which we catch as sinks in our flow
      // analysis.
      // 7.1.8 declares exceptions for unordered comparisons, which we catch as sinks in our flow
      // analysis.
    )
  }

  string getReason() { result = reason }
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
    node.asExpr() instanceof InvalidOperationExpr
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
    (
      // Case 1: NaNs shall not be compared, except to themselves
      exists(ComparisonOperation cmp |
        node.asExpr() = cmp.getAnOperand() and
        not hashCons(cmp.getLeftOperand()) = hashCons(cmp.getRightOperand())
      )
      or
      // Case 2: NaNs and infinities shall not be cast to integers
      exists(Conversion c |
        node.asExpr() = c.getUnconverted() and
        c.getExpr().getType() instanceof FloatingPointType and
        c.getType() instanceof IntegralType
      )
      //or
      //// Case 4: Functions shall not return NaNs or infinities
      //exists(ReturnStmt ret | node.asExpr() = ret.getExpr())
    )
  }
}

module InvalidNaNFlow = DataFlow::Global<InvalidNaNUsage>;

import InvalidNaNFlow::PathGraph

from
  Element elem, InvalidNaNFlow::PathNode source, InvalidNaNFlow::PathNode sink, string msg,
  string sourceString
where
  elem = MacroUnwrapper<Expr>::unwrapElement(sink.getNode().asExpr()) and
  not isExcluded(elem, FloatingTypes2Package::possibleMisuseOfUndetectedNaNQuery()) and
  (
    InvalidNaNFlow::flow(source.getNode(), sink.getNode()) and
    msg = "Invalid usage of possible $@." and
    sourceString =
      "NaN resulting from " + source.getNode().asExpr().(InvalidOperationExpr).getReason()
  )
select elem, source, sink, msg, source, sourceString

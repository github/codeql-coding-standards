/**
 * @id c/misra/possible-misuse-of-undetected-infinity
 * @name DIR-4-15: Evaluation of floating-point expressions shall not lead to the undetected generation of infinities
 * @description Evaluation of floating-point expressions shall not lead to the undetected generation
 *              of infinities.
 * @kind path-problem
 * @precision medium
 * @problem.severity warning
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

module InvalidInfinityUsage implements DataFlow::ConfigSig {
  /**
   * An operation which does not have Infinity as an input, but may produce Infinity, according
   * to the `RestrictedRangeAnalysis` module.
   */
  predicate isSource(DataFlow::Node node) {
    potentialSource(node) and
    not exists(DataFlow::Node prior |
      isAdditionalFlowStep(prior, node) and
      potentialSource(prior)
    )
  }

  /**
   * An operation which may produce Infinity acconding to the `RestrictedRangeAnalysis` module.
   */
  additional predicate potentialSource(DataFlow::Node node) {
    node.asExpr() instanceof Operation and
    exprMayEqualInfinity(node.asExpr(), _)
  }

  predicate isBarrierOut(DataFlow::Node node) {
    guardedNotFPClass(node.asExpr(), TInfinite())
    or
    exists(Expr e |
      e.getType() instanceof IntegralType and
      e = node.asConvertedExpr()
    )
  }

  /**
   * An additional flow step to handle operations which propagate Infinity.
   *
   * This double checks that an Infinity may propagate by checking the `RestrictedRangeAnalysis`
   * value estimate. This is conservative, since `RestrictedRangeAnalysis` is performed locally
   * in scope with unanalyzable values in a finite range. However, this conservative approach
   * leverages analysis of guards and other local conditions to avoid false positives.
   */
  predicate isAdditionalFlowStep(DataFlow::Node source, DataFlow::Node sink) {
    exists(Operation o |
      o.getAnOperand() = source.asExpr() and
      o = sink.asExpr() and
      potentialSource(sink)
    )
  }

  predicate isSink(DataFlow::Node node) {
    node instanceof InvalidInfinityUsage and
    (
      // Require that range analysis finds this value potentially infinite, to avoid false positives
      // in the presence of guards. This may induce false negatives.
      exprMayEqualInfinity(node.asExpr(), _)
      or
      // Unanalyzable expressions are not checked against range analysis, which assumes a finite
      // range.
      not RestrictedRangeAnalysis::canBoundExpr(node.asExpr())
      or
      node.asExpr().(VariableAccess).getTarget() instanceof Parameter
    )
  }
}

class InvalidInfinityUsage extends DataFlow::Node {
  string description;

  InvalidInfinityUsage() {
    // Case 2: NaNs and infinities shall not be cast to integers
    exists(Conversion c |
      asExpr() = c.getUnconverted() and
      c.getExpr().getType() instanceof FloatingPointType and
      c.getType() instanceof IntegralType and
      description = "cast to integer."
    )
    or
    // Case 3: Infinities shall not underflow or otherwise produce finite values
    exists(BinaryOperation op |
      asExpr() = op.getRightOperand() and
      op.getOperator() = "/" and
      description = "divisor, which would silently underflow and produce zero."
    )
  }

  string getDescription() { result = description }
}

module InvalidInfinityFlow = DataFlow::Global<InvalidInfinityUsage>;

import InvalidInfinityFlow::PathGraph

from
  Element elem, InvalidInfinityFlow::PathNode source, InvalidInfinityFlow::PathNode sink,
  InvalidInfinityUsage usage, Expr sourceExpr, string sourceString, Function function,
  string computedInFunction
where
  elem = MacroUnwrapper<Expr>::unwrapElement(sink.getNode().asExpr()) and
  not InvalidInfinityFlow::PathGraph::edges(_, source, _, _) and
  not InvalidInfinityFlow::PathGraph::edges(sink, _, _, _) and
  not isExcluded(elem, FloatingTypes2Package::possibleMisuseOfUndetectedInfinityQuery()) and
  not sourceExpr.isFromTemplateInstantiation(_) and
  not usage.asExpr().isFromTemplateInstantiation(_) and
  usage = sink.getNode() and
  sourceExpr = source.getNode().asExpr() and
  function = sourceExpr.getEnclosingFunction() and
  InvalidInfinityFlow::flow(source.getNode(), usage) and
  (
    if not sourceExpr.getEnclosingFunction() = usage.asExpr().getEnclosingFunction()
    then computedInFunction = "computed in function $@ "
    else computedInFunction = ""
  ) and
  (
    if sourceExpr instanceof DivExpr
    then sourceString = "from division by zero"
    else sourceString = sourceExpr.toString()
  )
select elem, source, sink,
  "Possibly infinite float value $@ " + computedInFunction + "flows to " + usage.getDescription(),
  sourceExpr, sourceString, function, function.getName()

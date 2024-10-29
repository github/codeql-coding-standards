/**
 * @id c/misra/possible-undetected-na-nor-infinity
 * @name DIR-4-15: Evaluation of floating-point expressions shall not lead to the undetected generation of infinities
 * @description Evaluation of floating-point expressions shall not lead to the undetected generation
 *              of infinities and NaNs.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/dir-4-15
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.dataflow.new.TaintTracking
import semmle.code.cpp.controlflow.Dominance
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

class CantHandleInfinityFunction extends Function {
  CantHandleInfinityFunction() {
    not hasDefinition() and not getName() = "__fpclassifyl"
  }
}

class InfinityCheckedExpr extends Expr {
  InfinityCheckedExpr() {
    exists(MacroInvocation mi |
      mi.getMacroName() = ["isfinite", "isinf"] and
      mi.getExpr() = this)
  }

  Expr getCheckedExpr() {
    result = this.(ConditionalExpr).getThen().(LTExpr).getLesserOperand().(BitwiseAndExpr).getLeftOperand().(FunctionCall).getArgument(0)
  }
}


signature module ResourceLeakConfigSig {
  predicate isResource(DataFlow::Node node);
  predicate isFree(DataFlow::Node node, DataFlow::Node resource);
  default ControlFlowNode outOfScope(DataFlow::Node resource) {
    result = resource.asExpr().getEnclosingFunction().getBlock().getLastStmt()
  }

  default predicate isAlias(DataFlow::Node alias, DataFlow::Node resource) {
    isResource(resource) and
    DataFlow::localFlow(resource, alias)
  }
}

module ResourceLeak<ResourceLeakConfigSig Config> {

  predicate isLeaked(DataFlow::Node resource, ControlFlowNode cfgNode) {
    resource.asExpr() = cfgNode
    or
    isLeaked(resource, cfgNode.getAPredecessor()) and
    not exists(DataFlow::Node free, DataFlow::Node freed |
      free.asExpr() = cfgNode and
      Config::isFree(free, freed) and
      Config::isAlias(freed, resource)
    )
  }

  private ControlFlowNode getARawLeak(DataFlow::Node resource) {
    Config::isResource(resource) and
    result = Config::outOfScope(resource) and
    isLeaked(resource, result)
  }

  ControlFlowNode getALeak(DataFlow::Node resource) {
    result = getARawLeak(resource) and
    not exists(DataFlow::Node dealiased |
      Config::isResource(dealiased) and
      Config::isAlias(resource, dealiased) and
      not resource = dealiased and
      result = getARawLeak(dealiased)
    ) and not exists(ControlFlowNode dominator |
      dominator = getARawLeak(resource) and
      strictlyDominates(dominator, result)
    )
  }
}

module MissedInfinityConfig implements ResourceLeakConfigSig {
  predicate isResource(DataFlow::Node node) {
    //exists(BinaryOperation expr |
    //  expr = node.asExpr() and
    //  expr.getOperator() = "/" and
    //  upperBound(expr.getRightOperand()) <= 0 and
    //  lowerBound(expr.getRightOperand()) >= 0
    //)
    [upperBound(node.asExpr()), lowerBound(node.asExpr())].toString() = "Infinity"
    and not node.asExpr() instanceof VariableAccess
    and not node.asExpr() instanceof ArrayExpr
  }

  predicate test(Expr expr, string lowerBound, string upperBound) {
    expr.getType() instanceof FloatingPointType
    and
    lowerBound = lowerBound(expr).toString() and
    upperBound = upperBound(expr).toString()
  }

  predicate isFree(DataFlow::Node node, DataFlow::Node resource) {
    isResource(resource) and
    (
    node.asExpr().(InfinityCheckedExpr).getCheckedExpr() = resource.asExpr()
    or not [lowerBound(node.asExpr()), upperBound(node.asExpr())].toString() = "Infinity" and
    isMove(node, resource)
    )
  }

  predicate isMove(DataFlow::Node node, DataFlow::Node moved) {
    isResource(moved) and
    isAlias(node, moved) and
    not exists(DataFlow::Node laterUse, ControlFlowNode later |
      later = laterUse.asExpr() and
      later = node.asExpr().getASuccessor+() and
      globalValueNumber(laterUse.asExpr()) = globalValueNumber(moved.asExpr())
    )
  }

  ControlFlowNode outOfScope(DataFlow::Node resource) {
    result = resource.asExpr().getEnclosingFunction().getBlock().getLastStmt()
    or exists(AssignExpr assign, DataFlow::Node alias |
      assign.getRValue() = alias.asExpr() and
      isAlias(alias, resource) and
      not assign.getRValue().(VariableAccess).getTarget() instanceof StackVariable and
      result = assign
    )
    or exists(FunctionCall fc | fc.getArgument(_) = resource.asExpr() and
      result = fc
    )
  }

  predicate isAlias(DataFlow::Node alias, DataFlow::Node resource) {
    TaintTracking::localTaint(resource, alias)
  }
}

import ResourceLeak<MissedInfinityConfig> as MissedInfinity

//from Expr value, FunctionCall fc
//where
//  not isExcluded(value, FloatingTypes2Package::possibleUndetectedNaNorInfinityQuery()) and
//  [lowerBound(value), upperBound(value)].toString() = "Infinity" and
//  value = fc.getAnArgument() and
//  fc.getTarget() instanceof CantHandleInfinityFunction and
//  not value instanceof InfinityCheckedExpr and
//  not exists (GuardCondition g |
//    g.controls(fc.getBasicBlock(), true) and
//    g instanceof InfinityCheckedExpr
//    // TODO check we check the right expr
//  )
//select
//  value, "possible use of unchecked infinity as arg to " + fc.getTarget().getName()

from DataFlow::Node node, ControlFlowNode leakPoint
where
  not isExcluded(node.asExpr(), FloatingTypes2Package::possibleUndetectedNaNorInfinityQuery()) and
  leakPoint = MissedInfinity::getALeak(node)
  select node, "Expression generates an infinity which is not checked before $@.", leakPoint, "external leak point"
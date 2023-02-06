/**
 * @id c/cert/restrict-pointer-references-overlapping-object
 * @name EXP43-C: Do not assign the value of a restrict-qualified pointer to another restrict-qualified pointer
 * @description Restrict qualified pointers referencing overlapping objects is undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp43-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.Dominance
import codingstandards.c.cert

/**
 * An `Expr` that is an assignment or initialization to a restrict-qualified pointer-type variable.
 */
class AssignmentOrInitializationToRestrictPtrValueExpr extends Expr {
  Variable v;

  AssignmentOrInitializationToRestrictPtrValueExpr() {
    this = v.getAnAssignedValue() and
    v.getType().hasSpecifier("restrict")
  }

  Variable getVariable() { result = v }
}

/**
 * Returns the target variable of a `VariableAccess`.
 * If the access is a field access, then the target is the `Variable` of the qualifier.
 */
Variable getAddressOfExprTargetBase(AddressOfExpr expr) {
  result = expr.getOperand().(ValueFieldAccess).getQualifier().(VariableAccess).getTarget()
  or
  result = expr.getOperand().(VariableAccess).getTarget()
}

/**
 * A data-flow configuration for tracking flow from an assignment or initialization to
 * an assignment to an `AssignmentOrInitializationToRestrictPtrValueExpr`.
 */
class AssignedValueToRestrictPtrValueConfiguration extends DataFlow::Configuration {
  AssignedValueToRestrictPtrValueConfiguration() {
    this = "AssignmentOrInitializationToRestrictPtrValueConfiguration"
  }

  override predicate isSource(DataFlow::Node source) {
    exists(Variable v | source.asExpr() = v.getAnAssignedValue())
  }

  override predicate isSink(DataFlow::Node sink) {
    sink.asExpr() instanceof AssignmentOrInitializationToRestrictPtrValueExpr
  }
}

from
  AssignedValueToRestrictPtrValueConfiguration config, DataFlow::Node sourceValue,
  AssignmentOrInitializationToRestrictPtrValueExpr expr,
  AssignmentOrInitializationToRestrictPtrValueExpr pre_expr
where
  not isExcluded(expr, Pointers3Package::restrictPointerReferencesOverlappingObjectQuery()) and
  (
    // If the same expressions flows to two unique `AssignmentOrInitializationToRestrictPtrValueExpr`
    // in the same block, then the two variables point to the same (overlapping) object
    expr.getEnclosingBlock() = pre_expr.getEnclosingBlock() and
    (
      config.hasFlow(sourceValue, DataFlow::exprNode(pre_expr)) and
      config.hasFlow(sourceValue, DataFlow::exprNode(expr))
      or
      // Expressions referring to the address of the same variable can also result in aliasing
      getAddressOfExprTargetBase(expr) = getAddressOfExprTargetBase(pre_expr)
    ) and
    strictlyDominates(pragma[only_bind_out](pre_expr), pragma[only_bind_out](expr))
    or
    // Two restrict-qualified pointers in the same scope assigned to each other
    expr.(VariableAccess).getTarget().getType().hasSpecifier("restrict") and
    expr.(VariableAccess).getTarget().getParentScope() = expr.getVariable().getParentScope()
  )
select expr, "Assignment to restrict-qualified pointer $@ results in pointer aliasing.",
  expr.getVariable(), expr.getVariable().getName()

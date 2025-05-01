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
 *       external/cert/priority/p4
 *       external/cert/level/l3
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.Dominance
import codingstandards.c.cert
import codingstandards.cpp.Variable

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

  predicate isTargetRestrictQualifiedAndInSameScope() {
    this.(VariableAccess).getTarget().getType().hasSpecifier("restrict") and
    this.(VariableAccess).getTarget().getParentScope() = this.getVariable().getParentScope()
  }
}

/**
 * A data-flow configuration for tracking flow from an assignment or initialization to
 * an assignment to an `AssignmentOrInitializationToRestrictPtrValueExpr`.
 */
module AssignedValueToRestrictPtrValueConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(Variable v | source.asExpr() = v.getAnAssignedValue())
  }

  predicate isSink(DataFlow::Node sink) {
    sink.asExpr() instanceof AssignmentOrInitializationToRestrictPtrValueExpr
  }
}

module AssignedValueToRestrictPtrValueFlow =
  DataFlow::Global<AssignedValueToRestrictPtrValueConfig>;

from
  AssignmentOrInitializationToRestrictPtrValueExpr expr, DataFlow::Node sourceValue,
  string sourceMessage
where
  not isExcluded(expr, Pointers3Package::restrictPointerReferencesOverlappingObjectQuery()) and
  (
    // Two restrict-qualified pointers in the same scope assigned to each other
    expr.isTargetRestrictQualifiedAndInSameScope() and
    sourceValue.asExpr() = expr and
    sourceMessage = "the object pointed to by " + expr.(VariableAccess).getTarget().getName()
    or
    // If the same expressions flows to two unique `AssignmentOrInitializationToRestrictPtrValueExpr`
    // in the same block, then the two variables point to the same (overlapping) object
    not expr.isTargetRestrictQualifiedAndInSameScope() and
    exists(AssignmentOrInitializationToRestrictPtrValueExpr pre_expr |
      expr.getEnclosingBlock() = pre_expr.getEnclosingBlock() and
      (
        AssignedValueToRestrictPtrValueFlow::flow(sourceValue, DataFlow::exprNode(pre_expr)) and
        AssignedValueToRestrictPtrValueFlow::flow(sourceValue, DataFlow::exprNode(expr)) and
        sourceMessage = "the same source value"
        or
        // Expressions referring to the address of the same variable can also result in aliasing
        getAddressOfExprTargetBase(expr) = getAddressOfExprTargetBase(pre_expr) and
        sourceValue.asExpr() = pre_expr and
        sourceMessage = getAddressOfExprTargetBase(expr).getName() + " via address-of"
      ) and
      strictlyDominates(pragma[only_bind_out](pre_expr), pragma[only_bind_out](expr))
    )
  )
select expr, "Assignment to restrict-qualified pointer $@ results in pointers aliasing $@.",
  expr.getVariable(), expr.getVariable().getName(), sourceValue, sourceMessage

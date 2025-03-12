/**
 * @id c/misra/unsequenced-atomic-reads
 * @name RULE-13-2: The value of an atomic variable depend on its evaluation order and interleave of threads
 * @description The value of an atomic variable shall not depend on evaluation order and
 *              interleaving of threads.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-2
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.c.misra
import codingstandards.c.Ordering
import codingstandards.c.orderofevaluation.VariableAccessOrdering

class AtomicAccessInFullExpressionOrdering extends Ordering::Configuration {
  AtomicAccessInFullExpressionOrdering() { this = "AtomicAccessInFullExpressionOrdering" }

  override predicate isCandidate(Expr e1, Expr e2) {
    exists(AtomicVariableAccess a, AtomicVariableAccess b, FullExpr e | a = e1 and b = e2 |
      a.getTarget() = b.getTarget() and
      a.(ConstituentExpr).getFullExpr() = e and
      b.(ConstituentExpr).getFullExpr() = e and
      not a = b
    )
  }
}

/**
 * A read of a variable specified as `_Atomic`.
 *
 * Note, it may be accessed directly, or by passing its address into the std atomic functions.
 */
class AtomicVariableAccess extends VariableAccess {
  AtomicVariableAccess() { getTarget().getType().hasSpecifier("atomic") }

  /* Get the `atomic_<read|write>()` call this VarAccess occurs in. */
  FunctionCall getAtomicFunctionCall() {
    exists(AddressOfExpr addrParent, FunctionCall fc |
      fc.getTarget().getName().matches("__c11_atomic%") and
      addrParent = fc.getArgument(0) and
      addrParent.getAnOperand() = this and
      result = fc
    )
  }

  /**
   * Gets an assigned expr, either in the form `x = <result>` or `atomic_store(&x, <result>)`.
   */
  Expr getAnAssignedExpr() {
    result = getAtomicFunctionCall().getArgument(1)
    or
    exists(AssignExpr assign |
      assign.getLValue() = this and
      result = assign.getRValue()
    )
  }

  /**
   * Gets the expression holding this variable access, either in the form `x` or `atomic_read(&x)`.
   */
  Expr getARead() {
    result = getAtomicFunctionCall()
    or
    result = this
  }
}

from
  AtomicAccessInFullExpressionOrdering config, FullExpr e, Variable v, AtomicVariableAccess va1,
  AtomicVariableAccess va2
where
  not isExcluded(e, SideEffects3Package::unsequencedAtomicReadsQuery()) and
  e = va1.(ConstituentExpr).getFullExpr() and
  config.isUnsequenced(va1, va2) and
  v = va1.getTarget() and
  v = va2.getTarget() and
  // Exclude cases where the variable is assigned a value tainted by the other variable access.
  not exists(Expr write |
    write = va1.getAnAssignedExpr() and
    TaintTracking::localTaint(DataFlow::exprNode(va2.getARead()), DataFlow::exprNode(write))
  ) and
  // Impose an ordering, show the first access.
  va1.getLocation().isBefore(va2.getLocation(), _)
select e, "Atomic variable $@ has a $@ that is unsequenced with $@.", v, v.getName(), va1,
  "previous read", va2, "another read"

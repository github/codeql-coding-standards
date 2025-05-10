/**
 * @id c/misra/unsequenced-atomic-reads
 * @name RULE-13-2: The value of an atomic variable shall not depend on the evaluation order of interleaved threads
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
import codingstandards.cpp.StdFunctionOrMacro

class AtomicAccessInFullExpressionOrdering extends Ordering::Configuration {
  AtomicAccessInFullExpressionOrdering() { this = "AtomicAccessInFullExpressionOrdering" }

  override predicate isCandidate(Expr e1, Expr e2) {
    exists(AtomicVariableAccess a, AtomicVariableAccess b, FullExpr e | a = e1 and b = e2 |
      a.getTarget() = b.getTarget() and
      a.getARead().(ConstituentExpr).getFullExpr() = e and
      b.getARead().(ConstituentExpr).getFullExpr() = e and
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

  /* Get the `atomic_load()` call this VarAccess occurs in. */
  Expr getAtomicFunctionRead() {
    exists(AddressOfExpr addrParent, AtomicReadOrWriteCall fc |
      fc.getName().matches("atomic_load%") and
      // StdFunctionOrMacro arguments are not necessarily reliable, so we look for any AddressOfExpr
      // that is an argument to a call to `atomic_load`.
      addrParent = fc.getArgument(0) and
      addrParent.getAnOperand() = this and
      result = fc.getExpr()
    )
  }

  /* Get the `atomic_store()` call this VarAccess occurs in. */
  Expr getAtomicFunctionWrite(Expr storedValue) {
    exists(AddressOfExpr addrParent, AtomicReadOrWriteCall fc |
      addrParent = fc.getArgument(0) and
      addrParent.getAnOperand() = this and
      result = fc.getExpr() and
      (
        fc.getName().matches(["%store%", "%exchange%", "%fetch_%"]) and
        not fc.getName().matches("%compare%") and
        storedValue = fc.getArgument(1)
        or
        fc.getName().matches(["%compare%"]) and
        storedValue = fc.getArgument(2)
      )
    )
  }

  /**
   * Gets an assigned expr, either in the form `x = <result>` or `atomic_store(&x, <result>)`.
   */
  Expr getAnAssignedExpr() {
    exists(getAtomicFunctionWrite(result))
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
    result = getAtomicFunctionRead()
    or
    result = this
  }
}

from
  AtomicAccessInFullExpressionOrdering config, FullExpr e, Variable v, AtomicVariableAccess va1,
  AtomicVariableAccess va2, Expr va1Read, Expr va2Read
where
  not isExcluded(e, SideEffects3Package::unsequencedAtomicReadsQuery()) and
  va1Read = va1.getARead() and
  va2Read = va2.getARead() and
  e = va1Read.(ConstituentExpr).getFullExpr() and
  // Careful here. The `VariableAccess` in a pair of atomic function calls may not be unsequenced,
  // for instance in gcc where atomic functions expand to StmtExprs, which have clear sequences.
  // In this case, the result of `getARead()` for a pair of atomic function calls may be
  // unsequenced even though the `VariableAccess`es within those calls are not.
  config.isUnsequenced(va1Read, va2Read) and
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

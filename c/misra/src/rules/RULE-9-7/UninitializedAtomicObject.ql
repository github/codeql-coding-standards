/**
 * @id c/misra/uninitialized-atomic-object
 * @name RULE-9-7: Atomic objects shall be appropriately initialized before being accessed
 * @description Atomic objects that do not have static storage duration shall be initialized with a
 *              value or by using 'atomic_init()'.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-9-7
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.StdFunctionOrMacro
import semmle.code.cpp.controlflow.Dominance

class ThreadSpawningFunction extends Function {
  ThreadSpawningFunction() {
    this.hasName("pthread_create")
    or
    this.hasName("thrd_create")
    or
    exists(FunctionCall fc |
      fc.getTarget() instanceof ThreadSpawningFunction and
      fc.getEnclosingFunction() = this
    )
  }
}

class AtomicInitAddressOfExpr extends AddressOfExpr {
  AtomicInitAddressOfExpr() {
    // StdFunctionOrMacro arguments are not necessarily reliable, so we look for any AddressOfExpr
    // that is an argument to a call to `atomic_init`.
    exists(AtomicInitCall c | this = c.getAnArgument())
  }
}

ControlFlowNode getARequiredInitializationPoint(LocalScopeVariable v) {
  result = v.getParentScope().(BlockStmt).getFollowingStmt()
  or
  exists(DeclStmt decl |
    decl.getADeclaration() = v and
    result =
      any(FunctionCall fc |
        fc.getTarget() instanceof ThreadSpawningFunction and
        fc.getEnclosingBlock().getEnclosingBlock*() = v.getParentScope() and
        fc.getAPredecessor*() = decl
      )
  )
}

from VariableDeclarationEntry decl, Variable v
where
  not isExcluded(decl, Concurrency7Package::uninitializedAtomicObjectQuery()) and
  v = decl.getVariable() and
  v.getUnderlyingType().hasSpecifier("atomic") and
  not v.isTopLevel() and
  not exists(v.getInitializer()) and
  exists(ControlFlowNode missingInitPoint |
    missingInitPoint = getARequiredInitializationPoint(v) and
    // Check for `atomic_init(&v)`
    not exists(AtomicInitAddressOfExpr initialization |
      initialization.getOperand().(VariableAccess).getTarget() = v and
      dominates(initialization, missingInitPoint)
    ) and
    // Check for `unknown_func(&v)` which may call `atomic_init` on `v`.
    not exists(FunctionCall fc |
      fc.getAnArgument().(AddressOfExpr).getOperand().(VariableAccess).getTarget() = v and
      dominates(fc, missingInitPoint)
    )
  )
select decl,
  "Atomic object '" + v.getName() + "' has no initializer or corresponding use of 'atomic_init()'."

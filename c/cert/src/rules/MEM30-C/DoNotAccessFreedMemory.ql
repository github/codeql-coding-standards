/**
 * @id c/cert/do-not-access-freed-memory
 * @name MEM30-C: Do not access freed memory
 * @description Accessing memory that has been deallocated is undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/mem30-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Allocations
import semmle.code.cpp.controlflow.StackVariableReachability

/** `e` is an expression that frees the memory pointed to by `v`. */
predicate isFreeExpr(Expr e, StackVariable v) {
  exists(VariableAccess va | va.getTarget() = v and freeExprOrIndirect(e, va, _))
}

/** `e` is an expression that accesses `v` but is not the lvalue of an assignment. */
predicate isAccessExpr(Expr e, StackVariable v) {
  v.getAnAccess() = e and
  not exists(Assignment a | a.getLValue() = e)
  or
  isDerefByCallExpr(_, _, e, v)
}

/**
 * `va` is passed by value as (part of) the `i`th argument in
 * call `c`. The target function is either a library function
 * or a source code function that dereferences the relevant
 * parameter.
 */
predicate isDerefByCallExpr(Call c, int i, VariableAccess va, StackVariable v) {
  v.getAnAccess() = va and
  va = c.getAnArgumentSubExpr(i) and
  not c.passesByReference(i, va) and
  (c.getTarget().hasEntryPoint() implies isAccessExpr(_, c.getTarget().getParameter(i)))
}

class UseAfterFreeReachability extends StackVariableReachability {
  UseAfterFreeReachability() { this = "UseAfterFree" }

  override predicate isSource(ControlFlowNode node, StackVariable v) { isFreeExpr(node, v) }

  override predicate isSink(ControlFlowNode node, StackVariable v) { isAccessExpr(node, v) }

  override predicate isBarrier(ControlFlowNode node, StackVariable v) {
    definitionBarrier(v, node) or
    isFreeExpr(node, v)
  }
}

// This query is a modified version of the `UseAfterFree.ql`
// (cpp/use-after-free) query from the CodeQL standard library.
from UseAfterFreeReachability r, StackVariable v, Expr free, Expr e
where
  not isExcluded(e, InvalidMemory1Package::doNotAccessFreedMemoryQuery()) and
  r.reaches(free, v, e)
select e,
  "Pointer '" + v.getName().toString() + "' accessed but may have been previously freed $@.", free,
  "here"

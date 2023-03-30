/**
 * Provides a library which includes a `problems` predicate for reporting
 * memory allocations which are allocated but not freed before they go out of scope.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.controlflow.StackVariableReachability
import codingstandards.cpp.Allocations
import semmle.code.cpp.pointsto.PointsTo

predicate allocated(FunctionCall fc) { allocExpr(fc, _) }

/** An expression for which there exists a function call that might free it. */
class FreedExpr extends PointsToExpr {
  FreedExpr() { freeExprOrIndirect(_, this, _) }

  override predicate interesting() { freeExprOrIndirect(_, this, _) }
}

/**
 * Holds if `fc` is a call to a function that allocates memory that might be freed.
 */
predicate mallocCallMayBeFreed(FunctionCall fc) { allocated(fc) and anythingPointsTo(fc) }

/**
 * 'call' is either a direct call to f, or a possible call to f
 * via a function pointer.
 */
predicate mayCallFunction(Expr call, Function f) {
  call.(FunctionCall).getTarget() = f or
  call.(VariableCall).getVariable().getAnAssignedValue().getAChild*().(FunctionAccess).getTarget() =
    f
}

predicate allocCallOrIndirect(Expr e) {
  // direct memory allocation call
  allocated(e) and
  // We are only interested in memory allocation calls that are
  // actually freed somehow, as MemoryNeverFreed
  // will catch those that aren't.
  mallocCallMayBeFreed(e)
  or
  exists(ReturnStmt rtn |
    // indirect memory allocation call
    mayCallFunction(e, rtn.getEnclosingFunction()) and
    (
      // return memory allocation
      allocCallOrIndirect(rtn.getExpr())
      or
      // return variable assigned with allocated memory
      exists(Variable v |
        v = rtn.getExpr().(VariableAccess).getTarget() and
        allocCallOrIndirect(v.getAnAssignedValue()) and
        not assignedToFieldOrGlobal(v, _)
      )
    )
  )
}

predicate allocDefinition(StackVariable v, ControlFlowNode def) {
  exists(Expr expr | exprDefinition(v, def, expr) and allocCallOrIndirect(expr))
}

class MallocVariableReachability extends StackVariableReachabilityWithReassignment {
  MallocVariableReachability() { this = "MallocVariableReachability" }

  override predicate isSourceActual(ControlFlowNode node, StackVariable v) {
    allocDefinition(v, node)
  }

  override predicate isSinkActual(ControlFlowNode node, StackVariable v) {
    // node may be used in allocReaches
    exists(node.(AnalysedExpr).getNullSuccessor(v)) or
    freeExprOrIndirect(node, v.getAnAccess(), _) or
    assignedToFieldOrGlobal(v, node) or
    // node may be used directly in query
    v.getFunction() = node.(ReturnStmt).getEnclosingFunction()
  }

  override predicate isBarrier(ControlFlowNode node, StackVariable v) { definitionBarrier(v, node) }
}

/**
 * The value from malloc at `def` is still held in Variable `v` upon entering `node`.
 */
predicate mallocVariableReaches(StackVariable v, ControlFlowNode def, ControlFlowNode node) {
  exists(MallocVariableReachability r |
    // reachability
    r.reachesTo(def, _, node, v)
    or
    // accept def node itself
    r.isSource(def, v) and
    node = def
  )
}

class MallocReachability extends StackVariableReachabilityExt {
  MallocReachability() { this = "MallocReachability" }

  override predicate isSource(ControlFlowNode node, StackVariable v) { allocDefinition(v, node) }

  override predicate isSink(ControlFlowNode node, StackVariable v) {
    v.getFunction() = node.(ReturnStmt).getEnclosingFunction() and
    // exclude return statements that call a function and pass the pointer as an argument
    not exists(Expr arg |
      arg = node.(ReturnStmt).getExpr().(FunctionCall).getAnArgument() and
      arg = v.getAnAccess() and
      not dereferenced(arg)
    )
  }

  override predicate isBarrier(
    ControlFlowNode source, ControlFlowNode node, ControlFlowNode next, StackVariable v
  ) {
    isSource(source, v) and
    next = node.getASuccessor() and
    // the memory (stored in any variable `v0`) allocated at `source` is freed or
    // assigned to a global at node, or NULL checked on the edge node -> next.
    exists(StackVariable v0 | mallocVariableReaches(v0, source, node) |
      node.(AnalysedExpr).getNullSuccessor(v0) = next or
      freeExprOrIndirect(node, v0.getAnAccess(), _) or
      assignedToFieldOrGlobal(v0, node)
    )
  }
}

/**
 * The value returned by alloc `def` has not been freed, confirmed to be null,
 * or potentially leaked globally upon reaching `node` (regardless of what variable
 * it's still held in, if any).
 */
predicate mallocReaches(ControlFlowNode def, ControlFlowNode node) {
  exists(MallocReachability r | r.reaches(def, _, node))
}

predicate assignedToFieldOrGlobal(StackVariable v, Expr e) {
  // assigned to anything except a StackVariable
  // (typically a field or global, but for example also *ptr = v)
  e.(Assignment).getRValue() = v.getAnAccess() and
  not e.(Assignment).getLValue().(VariableAccess).getTarget() instanceof StackVariable
  or
  exists(Expr midExpr, Function mid, int arg |
    // indirect assignment
    e.(FunctionCall).getArgument(arg) = v.getAnAccess() and
    mayCallFunction(e, mid) and
    midExpr.getEnclosingFunction() = mid and
    assignedToFieldOrGlobal(mid.getParameter(arg), midExpr)
  )
  or
  // assigned to a field via constructor field initializer
  e.(ConstructorFieldInit).getExpr() = v.getAnAccess()
}

abstract class FreeMemoryWhenNoLongerNeededSharedSharedQuery extends Query { }

Query getQuery() { result instanceof FreeMemoryWhenNoLongerNeededSharedSharedQuery }

// note: this query is based on CloseFileHandleWhenNoLongerNeededShared.qll
query predicate problems(ControlFlowNode def, string message, Stmt ret, string retMsg) {
  not isExcluded(def, getQuery()) and
  message = "The memory allocated here may not be freed at $@." and
  retMsg = "this location" and
  (
    mallocReaches(def, ret) and
    not exists(StackVariable v |
      mallocVariableReaches(v, def, ret) and
      ret.getAChild*() = v.getAnAccess()
    )
    or
    allocated(def) and
    not mallocCallMayBeFreed(def) and
    ret = def.getControlFlowScope().getEntryPoint()
  )
}

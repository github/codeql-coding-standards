/**
 * Provides a library which includes a `problems` predicate for reporting an undefined member access through
 * an unitialized static pointer-to-member pointer.
 *
 * The implementation uses a control-flow based approach instead of a global data-flow approach because
 * the `DataFlow::UninitializedNode` models uninitialized local static variables, but not global uninitialized
 * static variables.
 *
 * Every static pointer variable is assigned an abstract value based on its default or assigned value at the start of every main-like
 * function in the program. For each program location reachable from a main-like function we track the set of possible abstract values
 * a static pointer variable can have and use this set to determine if a dereference can potentially dereference a null pointer.
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.EncapsulatingFunctions
import codingstandards.cpp.Nullness
import codingstandards.cpp.Expr

abstract class AccessOfUndefinedMemberThroughUninitializedStaticPointerSharedQuery extends Query { }

Query getQuery() {
  result instanceof AccessOfUndefinedMemberThroughUninitializedStaticPointerSharedQuery
}

/** A static pointer-to-member pointer. */
private class StaticMemberPointer extends Variable {
  StaticMemberPointer() { getUnspecifiedType() instanceof PointerToMemberType and isStatic() }
}

/** A type to represent to possible abstract values a static pointer-to-member pointer can point to. */
newtype TStaticMemberPointerAbstractValue =
  // Static pointer-to-member pointers that are not initialed explicitly are default initialized to nullptr.
  DefaultInitializedNullValue(StaticMemberPointer ptr, VariableDeclarationEntry vde) {
    vde.getDeclaration() = ptr and not ptr.hasInitializer()
  } or
  InitializedNullValue(StaticMemberPointer ptr, Expr val) {
    val = ptr.getInitializer().getExpr() and
    val instanceof NullValue
  } or
  // Static pointer-to-member pointers that are initialized are initialized with a null value
  AssignedNullValue(StaticMemberPointer ptr, Expr val) {
    // A null value tracked via the data flow graph
    exists(ControlFlowNode n |
      NullValueToAssignmentFlow::flow(_, DataFlow::exprNode(val)) and
      n.(Assignment).getLValue() = ptr.getAnAccess() and
      n.(Assignment).getRValue() = val
    )
    or
    // or a null value tracked through the control flow graph
    exists(StaticMemberPointerAbstractValue prevVal |
      pointsToMap(val, val.(VariableAccess).getTarget(), prevVal) and
      (prevVal = DefaultInitializedNullValue(_, _) or prevVal = InitializedNullValue(_, _))
    )
  } or
  InitializedNonNullValue(StaticMemberPointer ptr, Expr val) {
    ptr.getInitializer().getExpr() = val and
    val instanceof NullValue
  } or
  // or a non-null value.
  AssignedNonNullValue(StaticMemberPointer ptr, Expr val) {
    // A non-null value tracked via the data flow graph
    exists(ControlFlowNode n |
      NullValueToAssignmentFlow::flow(_, DataFlow::exprNode(val)) and
      n.(Assignment).getLValue() = ptr.getAnAccess() and
      n.(Assignment).getRValue() = val
    )
    or
    // or a non-null value tracked through the control flow graph
    exists(StaticMemberPointerAbstractValue prevVal |
      pointsToMap(val, val.(VariableAccess).getTarget(), prevVal) and
      prevVal = InitializedNonNullValue(_, _)
    )
  }

/** An abstract value that can be assumed by a static pointer-to-member pointer. */
private class StaticMemberPointerAbstractValue extends TStaticMemberPointerAbstractValue {
  string toString() {
    result = "default initialized null value" and this = DefaultInitializedNullValue(_, _)
    or
    exists(Expr val |
      result = "initialized null value " + val.toString() and
      this = InitializedNullValue(_, val)
      or
      result = "assigned null value " + val.toString() and
      this = AssignedNullValue(_, val)
      or
      result = "initialized non-null value " + val.toString() and
      this = InitializedNonNullValue(_, val)
      or
      result = "assigned non-null value " + val.toString() and
      this = AssignedNonNullValue(_, val)
    )
  }

  /** Holds if the value pointed to by the pointer can be a null value. */
  predicate maybeNull() {
    this = DefaultInitializedNullValue(_, _) or
    this = InitializedNullValue(_, _) or
    this = AssignedNullValue(_, _)
  }
}

/** Holds if at location `loc` the static pointer-to-member pointer `ptr` can assume the abstract value `val`. */
private predicate pointsToMap(
  ControlFlowNode loc, StaticMemberPointer ptr, StaticMemberPointerAbstractValue val
) {
  // If the static pointer-to-member pointer is assigned a value, return the extracted abstract value.
  if isAssigned(loc, ptr)
  then val = getAnAssignedValue(loc, ptr)
  else
    // Else, propagate a previous value.
    // When we are at a function call, the value is determined by the value at the end of the callee.
    if loc instanceof FunctionCall
    then
      exists(FunctionCall caller, Function callee |
        caller = loc and
        callee = caller.getTarget()
      |
        pointsToMap(callee, ptr, val)
      )
    else (
      // If it is not a function call we propagate the value forwards.
      exists(ControlFlowNode pred, StaticMemberPointerAbstractValue prevValue |
        pred = loc.getAPredecessor() and pointsToMap(pred, ptr, prevValue)
      |
        // Propagate value from a predecessor.
        val = prevValue
      )
      or
      // This is a special case where there is no predecessor to propagate the value from, so
      // we propagate the value the callers
      not exists(loc.getAPredecessor()) and
      exists(FunctionCall caller |
        loc.getEnclosingStmt().getEnclosingFunction().getACallToThisFunction() = caller
      |
        pointsToMap(caller.getAPredecessor(), ptr, val)
      )
    )
}

/** Holds if at location `loc` the static pointer-to-member pointer `ptr` is assigned a value. */
private predicate isAssigned(ControlFlowNode loc, StaticMemberPointer ptr) {
  loc.(Assignment).getLValue() = ptr.getAnAccess()
  or
  // The main like function assigns every static pointer-to-member pointer, so the CP is intended.
  exists(MainLikeFunction f | loc = f.getBlock())
}

/** Gets an assigned abstract value for the static pointer-to-member pointer `ptr` at location `loc`. */
private StaticMemberPointerAbstractValue getAnAssignedValue(
  ControlFlowNode loc, StaticMemberPointer ptr
) {
  exists(Assignment a |
    loc = a and
    a.getLValue() = ptr.getAnAccess() and
    (
      // A value can propagate from another static pointer-to-member pointer.
      // This case accounts for the propagation of static null initialized value that
      // isn't captured by data flow.
      exists(
        StaticMemberPointer other, VariableAccess otherAccess,
        StaticMemberPointerAbstractValue prevVal
      |
        otherAccess = other.getAnAccess() and
        DataFlow::localExprFlow(otherAccess, a.getRValue()) and
        pointsToMap(otherAccess, other, prevVal)
      |
        prevVal = DefaultInitializedNullValue(_, _) and
        result = AssignedNullValue(ptr, a.getRValue())
        or
        prevVal = InitializedNonNullValue(_, _) and
        result = AssignedNonNullValue(ptr, a.getRValue())
        or
        prevVal = InitializedNullValue(_, _) and result = AssignedNullValue(ptr, a.getRValue())
        or
        prevVal = AssignedNullValue(_, _) and result = AssignedNullValue(ptr, a.getRValue())
        or
        prevVal = AssignedNonNullValue(_, _) and result = AssignedNonNullValue(ptr, a.getRValue())
      )
      or
      not exists(StaticMemberPointer other |
        DataFlow::localExprFlow(other.getAnAccess(), a.getRValue())
      ) and
      (
        result = AssignedNullValue(ptr, a.getRValue())
        or
        result = AssignedNonNullValue(ptr, a.getRValue())
      )
    )
  )
  or
  exists(MainLikeFunction f |
    f.getBlock() = loc and
    (
      result = DefaultInitializedNullValue(ptr, _)
      or
      result = InitializedNullValue(ptr, _)
      or
      result = InitializedNonNullValue(ptr, _)
    )
  )
}

query predicate problems(
  PointerToMemberExpr memberAccess, string message, StaticMemberPointer ptr,
  string placeholderMessage
) {
  not isExcluded(memberAccess, getQuery()) and
  message =
    "A null pointer-to-member value originating from $@ is passed as the second operand to a pointer-to-member expression." and
  exists(StaticMemberPointerAbstractValue val |
    memberAccess.getPointerExpr() = ptr.getAnAccess() and
    pointsToMap(memberAccess, ptr, val) and
    val.maybeNull()
  ) and
  placeholderMessage = "here"
}

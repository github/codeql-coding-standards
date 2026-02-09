/**
 * Provides a library which includes a `problems` predicate for reporting issues with objects accessed
 * after being moved-from.
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.Exclusions
import codingstandards.cpp.standardlibrary.Utility

abstract class MovedFromObjectsUnspecifiedStateSharedQuery extends Query { }

Query getQuery() { result instanceof MovedFromObjectsUnspecifiedStateSharedQuery }

/*
 * `SafeRead` functions are guaranteed to leave the move-from object in a well-specified state.
 */

class SafeRead extends FunctionCall {
  SafeRead() {
    (getTarget() instanceof MoveConstructor or getTarget() instanceof MoveAssignmentOperator) and
    (
      getTarget().hasQualifiedName("std", "unique_ptr", _)
      or
      getTarget().hasQualifiedName("std", "shared_ptr", _)
      or
      getTarget().hasName("shared_ptr") and
      getArgument(0).getType().hasName("unique_ptr")
      or
      getTarget().hasQualifiedName("std", "week_ptr", _)
      or
      getTarget().hasQualifiedName("std", "basic_filebuf", _)
      or
      getTarget().hasQualifiedName("std", "thread", _)
      or
      getTarget().hasQualifiedName("std", "unique_lock", _)
      or
      getTarget().hasQualifiedName("std", "shared_lock", _)
      or
      getTarget().hasQualifiedName("std", "promise", _)
      or
      getTarget().hasQualifiedName("std", "future", _)
      or
      getTarget().hasQualifiedName("std", "shared_future", _)
      or
      getTarget().hasQualifiedName("std", "packaged_task", _)
    )
    or
    getTarget().hasQualifiedName("std", "basic_ios", "move")
  }
}

class ReassignedExpression extends Expr {
  ReassignedExpression() {
    exists(AssignExpr a |
      this = a.getLValue() or
      this = a.getLValue().(FieldAccess).getQualifier()
    )
    or
    exists(FunctionCall c |
      c.getTarget().hasName("operator=") and
      (
        this = c.getQualifier() or
        this = c.getQualifier().(FieldAccess).getQualifier()
      )
      or
      this = c.(DestructorCall).getQualifier()
    )
  }
}

query predicate problems(Expr e, string message, StdMoveCall f, string argDesc) {
  not isExcluded(e, getQuery()) and
  // reassignment is safe
  not e instanceof ReassignedExpression and
  // object moved to safe functions are preserved
  not exists(SafeRead safe | f = safe.getArgument(0)) and
  exists(DataFlow::DefinitionByReferenceNode def |
    def.asDefiningArgument() = f and
    DataFlow::localFlow(def, DataFlow::exprNode(e))
  ) and
  message = "The argument of the $@ may be indeterminate when accessed at this location." and
  argDesc = f.toString()
}

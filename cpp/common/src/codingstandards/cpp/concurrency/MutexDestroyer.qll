import cpp

/**
 * Models expressions that destroy mutexes.
 */
abstract class MutexDestroyer extends StmtParent {
  /**
   * Gets the expression that references the mutex being destroyed.
   */
  abstract Expr getMutexExpr();
}

/**
 * Models C style mutex destruction via `mtx_destroy`.
 */
class C11MutexDestroyer extends MutexDestroyer, FunctionCall {
  C11MutexDestroyer() { getTarget().getName() = "mtx_destroy" }

  /**
   * Returns the `Expr` being destroyed.
   */
  override Expr getMutexExpr() { result = getArgument(0) }
}

/**
 * Models a delete expression -- note it is necessary to add this in
 * addition to destructors to handle certain implementations of the
 * standard library which obscure the destructors of mutexes.
 */
class DeleteMutexDestroyer extends MutexDestroyer {
  DeleteMutexDestroyer() { this instanceof DeleteExpr }

  override Expr getMutexExpr() { this.(DeleteExpr).getExpr() = result }
}

/**
 * Models a possible mutex variable that if it goes
 * out of scope would destroy an underlying mutex.
 */
class LocalMutexDestroyer extends MutexDestroyer {
  Expr assignedValue;

  LocalMutexDestroyer() {
    exists(LocalVariable lv |
      // static types aren't destroyers
      not lv.isStatic() and
      // neither are pointers
      not lv.getType() instanceof PointerType and
      lv.getAnAssignedValue() = assignedValue and
      // map the location to the return statements of the
      // enclosing function
      exists(ReturnStmt rs |
        rs.getEnclosingFunction() = assignedValue.getEnclosingFunction() and
        rs = this
      )
    )
  }

  override Expr getMutexExpr() { result = assignedValue }
}

/**
 * Models implicit or explicit calls to the destructor of a mutex, either via
 * a `delete` statement or a variable going out of scope.
 */
class DestructorMutexDestroyer extends MutexDestroyer, DestructorCall {
  DestructorMutexDestroyer() { getTarget().getDeclaringType().hasQualifiedName("std", "mutex") }

  /**
   * Returns the `Expr` being deleted.
   */
  override Expr getMutexExpr() { getQualifier() = result }
}

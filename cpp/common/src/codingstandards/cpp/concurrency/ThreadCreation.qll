import cpp
private import codingstandards.cpp.concurrency.ControlFlow

/**
 * Models a call to a thread constructor via `std::thread`.
 */
class ThreadConstructorCall extends ConstructorCall, ThreadCreationFunction {
  Function f;

  ThreadConstructorCall() {
    getTarget().getDeclaringType().hasQualifiedName("std", "thread") and
    f = getArgument(0).(FunctionAccess).getTarget()
  }

  /**
   * Returns the function that will be invoked by this `std::thread`.
   */
  override Function getFunction() { result = f }

  override ControlFlowNode getNext() { result = getFunction().getEntryPoint() }
}

/**
 * Models a call to a thread creation via `thrd_create` or `pthread_create`.
 */
class CThreadCreateCall extends FunctionCall {
  Function f;
  int fArgIdx;

  CThreadCreateCall() {
    (
      getTarget().getName() = "thrd_create" and
      fArgIdx = 1
      or
      getTarget().getName() = "pthread_create" and
      fArgIdx = 2
    ) and
    (
      f = getArgument(fArgIdx).(FunctionAccess).getTarget() or
      f = getArgument(fArgIdx).(AddressOfExpr).getOperand().(FunctionAccess).getTarget()
    )
  }

  /**
   * Returns the function that will be invoked by this thread.
   */
  Function getFunction() { result = f }
}

/**
 * Models a call to a thread constructor via `thrd_create`.
 */
class C11ThreadCreateCall extends ThreadCreationFunction, CThreadCreateCall {
  C11ThreadCreateCall() { getTarget().getName() = "thrd_create" }

  /**
   * Returns the function that will be invoked by this thread.
   */
  override Function getFunction() { result = f }

  override ControlFlowNode getNext() { result = getFunction().getEntryPoint() }
}

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
 * Models a call to a thread constructor via `thrd_create`.
 */
class C11ThreadCreateCall extends ThreadCreationFunction {
  Function f;

  C11ThreadCreateCall() {
    getTarget().getName() = "thrd_create" and
    (
      f = getArgument(1).(FunctionAccess).getTarget() or
      f = getArgument(1).(AddressOfExpr).getOperand().(FunctionAccess).getTarget()
    )
  }

  /**
   * Returns the function that will be invoked by this thread.
   */
  override Function getFunction() { result = f }

  override ControlFlowNode getNext() { result = getFunction().getEntryPoint() }
}

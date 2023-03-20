import cpp

/**
 * A call to function `signal`
 */
class SignalCall extends FunctionCall {
  SignalCall() { this.getTarget().hasGlobalName("signal") }
}

/**
 * A signal handler
 */
class SignalHandler extends Function {
  SignalCall registration;

  SignalHandler() {
    // is a signal handler
    this = registration.getArgument(1).(FunctionAccess).getTarget()
  }

  SignalCall getRegistration() { result = registration }
}

/**
 * A call to `abort` or `_Exit` or `quick_exit`
 */
class AbortCall extends FunctionCall {
  AbortCall() { this.getTarget().hasGlobalName(["abort", "_Exit", "quick_exit"]) }
}

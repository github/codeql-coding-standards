import cpp
import codingstandards.cpp.exceptions.ExceptionFlow

/** Models calls to the `bad_alloc` constructor. */
class BadAllocConstructorCall extends ConstructorCall {
  BadAllocConstructorCall() { getTarget().getDeclaringType().hasQualifiedName("std", "bad_alloc") }
}

/** Models calls to exit functions. */
class ExitFunctionCall extends FunctionCall {
  ExitFunctionCall() { getTarget().getName() in ["exit", "abort"] }
}

/** Models functions that wrap exit functions. */
class ExitWrapper extends Function {
  ExitWrapper() { this = any(ExitFunctionCall efc).getEnclosingFunction() }
}

/**
 * Models the set of functions that set special handlers such as termination
 * and memory allocation handlers.
 */
class SetHandlerFunction extends FunctionCall {
  Function handler;

  SetHandlerFunction() {
    exists(Function f |
      f = getTarget() and
      f.hasQualifiedName("std", "set_terminate")
      or
      f.hasQualifiedName("std", "set_unexpected")
      or
      f.hasQualifiedName("std", "set_new_handler")
    ) and
    handler = getArgument(0).(FunctionAccess).getTarget()
  }

  /** Holds if this is a call to `set_terminate`. */
  predicate isTerminate() { getTarget().hasQualifiedName("std", "set_terminate") }

  /** Holds if this is a call to `set_unexpected`. */
  predicate isUnexpected() { getTarget().hasQualifiedName("std", "set_unexpected") }

  /** Holds if this is a call to `set_new_handler`. */
  predicate isNewHandler() { getTarget().hasQualifiedName("std", "set_new_handler") }

  /** Holds if this handler throws an exception. */
  predicate throwsAnException() { exists(getAFunctionThrownType(handler, _)) }

  /** Holds if this function throws an exception and it is of type `bad_alloc`. */
  predicate onlyThrowsBadAlloc() {
    forall(ExceptionType et | et = getAFunctionThrownType(handler, _) | et.getName() = "bad_alloc")
  }

  /** Gets the handler installed. */
  Function getHandler() { result = handler }

  /** Holds if the handler exists. */
  predicate exits() {
    exists(FunctionCall fc |
      fc = handler.getEntryPoint().getASuccessor*() and
      (
        fc.getTarget() instanceof ExitWrapper
        or
        fc instanceof ExitFunctionCall
      )
    )
  }
}

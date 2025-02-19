import cpp

/**
 * Models thread waiting functions.
 */
abstract class ThreadWait extends FunctionCall { }

/**
 * Models a call to a `std::thread` join.
 */
class CPPThreadWait extends ThreadWait {
  VariableAccess var;

  CPPThreadWait() {
    getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "thread") and
    getTarget().getName() = "join"
  }
}

/**
 * Models a call to `thrd_join` in C11.
 */
class C11ThreadWait extends ThreadWait {
  VariableAccess var;

  C11ThreadWait() { getTarget().getName() = "thrd_join" }
}

/**
 * Models thread detach functions.
 */
abstract class ThreadDetach extends FunctionCall { }

/**
 * Models a call to `thrd_detach` in C11.
 */
class C11ThreadDetach extends ThreadWait {
  VariableAccess var;

  C11ThreadDetach() { getTarget().getName() = "thrd_detach" }
}

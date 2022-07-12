import cpp

/**
 * Models a call to a a `std::thread` join.
 */
class ThreadWait extends FunctionCall {
  VariableAccess var;

  ThreadWait() {
    getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "thread") and
    getTarget().getName() = "join"
  }
}

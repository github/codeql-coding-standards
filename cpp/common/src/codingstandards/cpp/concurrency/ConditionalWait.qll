import cpp

/**
 * Models a function that conditionally waits.
 */
abstract class ConditionalWait extends FunctionCall { }

/**
 * Models a function in CPP that will conditionally wait.
 */
class CPPConditionalWait extends ConditionalWait {
  CPPConditionalWait() {
    exists(MemberFunction mf |
      mf = getTarget() and
      mf.getDeclaringType().hasQualifiedName("std", "condition_variable") and
      mf.getName() in ["wait", "wait_for", "wait_until"]
    )
  }
}

/**
 * Models a function in C that will conditionally wait.
 */
class CConditionalWait extends ConditionalWait {
  CConditionalWait() { getTarget().getName() in ["cnd_wait"] }
}

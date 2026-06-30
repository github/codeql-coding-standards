/**
 * Provides a library which includes a `problems` predicate for reporting errors
 * related to the use of condition variables.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Concurrency

abstract class PreserveSafetyWhenUsingConditionVariablesSharedQuery extends Query { }

Query getQuery() { result instanceof PreserveSafetyWhenUsingConditionVariablesSharedQuery }

/**
 * Models a notification arising from a conditional variable.
 */
abstract class ConditionalNotification extends FunctionCall {
  abstract predicate isNotifyOne();
}

class CPPConditionalNotification extends ConditionalNotification {
  string name;

  CPPConditionalNotification() {
    exists(MemberFunction mf |
      mf = getTarget() and
      mf.getDeclaringType().hasQualifiedName("std", "condition_variable") and
      mf.getName() = name
    )
  }

  override predicate isNotifyOne() { name in ["notify_one"] }
}

class C11ConditionalNotification extends ConditionalNotification {
  string name;

  C11ConditionalNotification() {
    exists(Function mf |
      mf = getTarget() and
      mf.getName() = ["cnd_signal", "cnd_broadcast"] and
      mf.getName() = name
    )
  }

  override predicate isNotifyOne() { name in ["cnd_signal"] }
}

/*
 * This query works by looking for single dispatch notifications in the context of a
 * function that is used in a thread.
 *
 * To avoid this problem a programmer may use `notify_all` or `cnd_broadcast` or use unique
 * condition variables. The problem of checking for correct usage of multiple
 * condition variables is especially non-trivial and thus this query
 * conservatively over-approximates potential issues with condition variables.
 *
 * Note that the check for using conditional variables within a loop is covered
 * by CON54-CPP
 */

query predicate problems(ConditionalNotification cn, string message) {
  not isExcluded(cn, getQuery()) and
  exists(ThreadedFunction tf |
    // the problematic types of uses of conditional variables
    // are the cases where single dispatch notification is used.
    cn.isNotifyOne() and
    // to be problematic this function should actually be used in a thread
    cn.getEnclosingFunction() = tf
  ) and
  message =
    "Possible unsafe usage of single dispatch notification which can lead to deadlocking of threads."
}

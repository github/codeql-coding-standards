/**
 * @id cpp/cert/preserve-thread-safety-and-liveness-when-using-condition-variables
 * @name CON55-CPP: Preserve thread safety and liveness when using condition variables
 * @description Usage of `notify_one` within a thread can lead to potential deadlocks and liveness
 *              problems.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con55-cpp
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Concurrency

/**
 * Models a conditional variable denoted by `std::condition_variable`.
 */
class ConditionalVariable extends Variable {
  ConditionalVariable() {
    getUnderlyingType().(Class).hasQualifiedName("std", "condition_variable")
  }
}

/**
 * Models a notification arising from a conditional variable.
 */
class ConditionalNotification extends FunctionCall {
  string name;

  ConditionalNotification() {
    exists(MemberFunction mf |
      mf = getTarget() and
      mf.getDeclaringType().hasQualifiedName("std", "condition_variable") and
      mf.getName() = name
    )
  }

  predicate isNotifyOne() { name in ["notify_one"] }
}

/**
 * Models a conditional function, which is a function that depends on the value
 * of a conditional variable.
 */
class ConditionalFunction extends Function {
  ConditionalFunction() {
    exists(ConditionalVariable cv | cv.getAnAccess().getEnclosingFunction() = this)
  }
}

/*
 * This query works by looking for usages of `notify_one` in the context of a
 * function that is used in a thread.
 *
 * To avoid this problem a programmer may use `notify_all` or use unique
 * condition variables. The problem of checking for correct usage of multiple
 * condition variables is especially non-trivial and thus this query
 * conservatively over-approximates potential issues with condition variables.
 *
 * Note that the check for using conditional variables within a loop is covered
 * by CON54-CPP
 */

from ConditionalNotification cv, ThreadedFunction tf
where
  not isExcluded(cv,
    ConcurrencyPackage::preserveThreadSafetyAndLivenessWhenUsingConditionVariablesQuery()) and
  // the problematic types of uses of conditional variables
  // are the cases where `notify_one` is used.
  cv.isNotifyOne() and
  // to be problematic this function should actually be used in a thread
  cv.getEnclosingFunction() = tf
select cv, "Possible unsafe usage of `notify_one` which can lead to deadlocking of threads."

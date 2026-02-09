/**
 * @id c/cert/do-not-access-shared-objects-in-signal-handlers
 * @name SIG31-C: Do not access shared objects in signal handlers
 * @description Do not access shared objects in signal handlers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/sig31-c
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p9
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Signal

/**
 * Does not an access an external variable except
 * to assign a value to a volatile static variable of sig_atomic_t type
 */
class UnsafeSharedVariableAccess extends VariableAccess {
  UnsafeSharedVariableAccess() {
    // excluding `volatile sig_atomic_t` type
    not this.getType().(SigAtomicType).isVolatile() and
    exists(Variable target | target = this.getTarget() |
      // static or thread local storage duration
      (
        target instanceof StaticStorageDurationVariable or
        target.isThreadLocal()
      ) and
      // excluding lock-free atomic objects
      not exists(MacroInvocation mi, VariableAccess va | va.getTarget() = target |
        mi.getMacroName() = "atomic_is_lock_free" and
        mi.getExpr().getChild(0) = va.getEnclosingElement*()
      )
    )
  }
}

from UnsafeSharedVariableAccess va, SignalHandler handler
where
  not isExcluded(va, SignalHandlersPackage::doNotAccessSharedObjectsInSignalHandlersQuery()) and
  handler = va.getEnclosingFunction()
select va, "Shared object access within a $@ can lead to undefined behavior.",
  handler.getRegistration(), "signal handler"

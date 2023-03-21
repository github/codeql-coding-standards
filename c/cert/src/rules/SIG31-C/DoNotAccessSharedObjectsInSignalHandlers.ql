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
    // static or thread local storage duration
    (
      this.getTarget() instanceof StaticStorageDurationVariable or
      this.getTarget().isThreadLocal()
    ) and
    // excluding `volatile sig_atomic_t` type
    not this.getType().(SigAtomicType).isVolatile() and
    // excluding lock-free atomic objects
    not exists(MacroInvocation mi, VariableAccess va |
      mi.getMacroName() = "atomic_is_lock_free" and
      mi.getExpr().getChild(0) = va.getEnclosingElement*() and
      va.getTarget() = this.getTarget()
    )
  }
}

from UnsafeSharedVariableAccess va, SignalHandler handler
where
  not isExcluded(va, SignalHandlersPackage::doNotAccessSharedObjectsInSignalHandlersQuery()) and
  handler = va.getEnclosingFunction()
select va, "Shared object access within a $@ can lead to undefined behavior.",
  handler.getRegistration(), "signal handler"

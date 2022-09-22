/**
 * @id c/misra/only-test-errno-right-after-errno-setting-function
 * @name RULE-22-10: The value of errno shall only be tested when the last function to be called was an
 * @description The value of errno shall only be tested when the last function to be called was an
 *              errno-setting-function.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-10
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Errno

/*
 * A call to an `ErrnoSettingFunction`
 */

class ErrnoSettingFunctionCall extends FunctionCall {
  ErrnoSettingFunctionCall() { this.getTarget() instanceof ErrnoSettingFunction }
}

/*
 * CFG nodes preceding a `errno` test
 */

ControlFlowNode notSetPriorToErrnoTest(EqualityOperation eg) {
  result = eg
  or
  exists(ControlFlowNode mid |
    result = mid.getAPredecessor() and
    mid = notSetPriorToErrnoTest(eg) and
    // stop recursion after first problem occurrence
    not mid = any(MaySetErrnoCall c) and
    // stop recursion on an errno-setting function call
    not result = any(ErrnoSettingFunctionCall c)
  )
}

/*
 * A function call that is not part of the `errno` macro expansion
 */

class MaySetErrnoCall extends FunctionCall {
  MaySetErrnoCall() {
    not inmacroexpansion(this, any(MacroInvocation ma | ma.getMacroName() = "errno"))
  }
}

from EqualityOperation eq, ControlFlowNode cause
where
  not isExcluded(eq, Contracts3Package::onlyTestErrnoRightAfterErrnoSettingFunctionQuery()) and
  cause = notSetPriorToErrnoTest(eq) and
  eq.getAnOperand() = any(MacroInvocation ma | ma.getMacroName() = "errno").getExpr() and
  (
    // `errno` is not set anywhere in the function
    cause = eq.getEnclosingFunction().getBlock()
    or
    // `errno` is not set after a non-errno-setting function call
    cause = any(MaySetErrnoCall c)
  )
select eq, "The value of `errno` shell only be tested after an errno-setting function call."

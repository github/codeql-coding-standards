/**
 * @id c/misra/only-test-errno-right-after-errno-setting-function
 * @name RULE-22-10: The value of errno shall only be tested when the last function to be called was an
 * @description The value of errno shall only be tested when the last function to be called was an
 *              errno-setting-function
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-10
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

ControlFlowNode notSetPriorToErrnoTest(ControlStructure eg) {
  result = eg
  or
  exists(ControlFlowNode mid |
    result = mid.getAPredecessor() and
    mid = notSetPriorToErrnoTest(eg) and
    // stop recursion after first problem occurrence
    not mid = any(FunctionCall fc) and
    // stop recursion on an errno-setting function call
    not result = any(ErrnoSettingFunctionCall fc)
  )
}

from ControlStructure eg, ControlFlowNode cause
where
  not isExcluded(eg, Contracts3Package::onlyTestErrnoRightAfterErrnoSettingFunctionQuery()) and
  cause = notSetPriorToErrnoTest(eg) and
  eg.getControllingExpr() instanceof ErrnoGuard and
  (
    // `errno` is not set anywhere in the function
    cause = eg.getEnclosingFunction().getBlock()
    or
    // `errno` is not set after a non-errno-setting function call
    cause = any(FunctionCall fc)
  )
select eg, "The value of `errno` shell only be tested after an errno-setting function call."

/**
 * @id c/misra/errno-set-to-zero-prior-to-call
 * @name RULE-22-8: The value of errno shall be set to zero prior to a call to an errno-setting-function
 * @description The value of errno shall be set to zero prior to a call to an
 *              errno-setting-function. Not setting the value leads to incorrectly identifying
 *              errors.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-8
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Errno

/**
 * A call to an `ErrnoSettingFunction`
 */
class ErrnoSettingFunctionCall extends FunctionCall {
  ErrnoSettingFunctionCall() { this.getTarget() instanceof ErrnoSettingFunction }
}

/**
 * CFG nodes preceding a `ErrnoSettingFunctionCall`
 */
ControlFlowNode notZeroedPriorToErrnoSet(ErrnoSettingFunctionCall fc) {
  result = fc
  or
  exists(ControlFlowNode mid |
    result = mid.getAPredecessor() and
    mid = notZeroedPriorToErrnoSet(fc) and
    // stop recursion when `errno` is set to zero
    not result instanceof ErrnoZeroed and
    not result = any(ErrnoGuard g).getZeroedSuccessor()
  )
}

from ErrnoSettingFunctionCall fc, ControlFlowNode cause
where
  not isExcluded(fc, Contracts3Package::errnoSetToZeroAfterCallQuery()) and
  cause = notZeroedPriorToErrnoSet(fc) and
  (
    // `errno` is not reset anywhere in the function
    cause = fc.getEnclosingFunction().getBlock()
    or
    // `errno` is not reset after a call to an errno-setting function
    cause = any(ErrnoSettingFunctionCall ec | ec != fc)
    or
    // `errno` is not reset after a call to a function
    cause = any(FunctionCall fc2 | fc2 != fc)
    or
    // `errno` value is known to be != 0
    cause = any(ErrnoGuard g).getNonZeroedSuccessor()
  )
select fc, "The value of `errno` may be different than `0` when this function is called."

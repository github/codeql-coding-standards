/**
 * @id c/cert/errno-not-set-to-zero
 * @name ERR30-C: Errno is not set to zero prior to an errno-setting call
 * @description Set errno to zero prior to each call to an errno-setting function. Failing to do so
 *              might end in spurious errno values.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err30-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Errno

/**
 * CFG nodes preceding a `ErrnoSettingFunctionCall`
 */
ControlFlowNode notZeroedPriorToErrnoSet(InBandErrnoSettingFunctionCall fc) {
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

from InBandErrnoSettingFunctionCall fc, ControlFlowNode cause
where
  not isExcluded(cause, Contracts4Package::errnoNotSetToZeroQuery()) and
  cause = notZeroedPriorToErrnoSet(fc) and
  (
    // `errno` is not reset anywhere in the function
    cause = fc.getEnclosingFunction().getBlock()
    or
    // `errno` is not reset after a call to an errno-setting function
    cause = any(InBandErrnoSettingFunctionCall ec | ec != fc)
    or
    // `errno` is not reset after a call to a function
    cause = any(FunctionCall fc2 | fc2 != fc)
    or
    // `errno` value is known to be != 0
    cause = any(ErrnoGuard g).getNonZeroedSuccessor()
  )
select fc, "The value of `errno` may be different than `0` when this function is called."

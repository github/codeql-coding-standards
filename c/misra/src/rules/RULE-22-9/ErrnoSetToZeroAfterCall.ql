/**
 * @id c/misra/errno-set-to-zero-after-call
 * @name RULE-22-9: The value of errno shall be tested against zero after calling an errno-setting-function
 * @description The value of errno shall be tested against zero after calling an
 *              errno-setting-function. Not testing the value leads to unidentified errors.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-9
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Errno

/**
 * CFG nodes following a `ErrnoSettingFunctionCall`
 */
ControlFlowNode notTestedAfterErrnoSet(InBandErrnoSettingFunctionCall fc) {
  result = fc
  or
  exists(ControlFlowNode mid |
    result = mid.getASuccessor() and
    mid = notTestedAfterErrnoSet(fc) and
    // stop recursion when `errno` is checked
    not result = any(ControlStructure i | i.getControllingExpr() instanceof ErrnoGuard)
  )
}

from InBandErrnoSettingFunctionCall fc, ControlFlowNode cause
where
  not isExcluded(fc, Contracts3Package::errnoSetToZeroAfterCallQuery()) and
  cause = notTestedAfterErrnoSet(fc) and
  (
    // `errno` is not checked anywhere in the function
    cause = fc.getEnclosingFunction()
    or
    // `errno` is not checked before a call to a function
    cause = any(FunctionCall fc2 | fc2 != fc)
  )
select fc, "The value of `errno` is not tested against `0` after the call."

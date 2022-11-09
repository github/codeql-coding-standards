/**
 * @id c/cert/setlocale-might-set-errno
 * @name ERR30-C: Do not rely solely on errno to determine if en error occurred in setlocale
 * @description Do not rely solely on errno to determine if en error occurred in setlocale.
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

class SetlocaleFunctionCall extends FunctionCall {
  SetlocaleFunctionCall() { this.getTarget().hasGlobalName("setlocale") }
}

/**
 * An `errno` read after setlocale
 */
ControlFlowNode errnoChecked(SetlocaleFunctionCall setlocale) {
  result = setlocale
  or
  exists(ControlFlowNode mid |
    result = mid.getASuccessor() and
    mid = errnoChecked(setlocale) and
    // stop recursion on a following errno-setting function call
    not result instanceof OutOfBandErrnoSettingFunctionCert and
    not result instanceof InBandErrnoSettingFunction
  )
}

/**
 * CFG nodes preceding a call to setlocale
 */
ControlFlowNode notZeroedPriorToSetlocale(SetlocaleFunctionCall fc) {
  result = fc
  or
  exists(ControlFlowNode mid |
    result = mid.getAPredecessor() and
    mid = notZeroedPriorToSetlocale(fc) and
    // stop recursion when `errno` is set to zero
    not result instanceof ErrnoZeroed and
    not result = any(ErrnoGuard g).getZeroedSuccessor()
  )
}

/**
 * A successor of a `setlocale` call appearing
 * before a check of the return value
 */
ControlFlowNode returnNotCheckedAfter(SetlocaleFunctionCall setlocale) {
  result = setlocale
  or
  exists(ControlFlowNode mid |
    result = mid.getASuccessor() and
    mid = returnNotCheckedAfter(setlocale) and
    // stop recursion on a return value check
    not (
      any(ControlStructure cs).getControllingExpr() = result and
      DataFlow::localExprFlow(setlocale, result.(Operation).getAnOperand*())
    ) and
    // stop recursion on a following errno setting function call
    not result instanceof SetlocaleFunctionCall
  )
}

from SetlocaleFunctionCall setlocale, ErrnoRead check, string msg
where
  not isExcluded(setlocale, Contracts4Package::setlocaleMightSetErrnoQuery()) and
  // errno is checked after setlocale
  check = errnoChecked(setlocale) and
  (
    // errno is not set to zero before the call
    exists(ControlFlowNode cause | cause = notZeroedPriorToSetlocale(setlocale) |
      // `errno` is not reset anywhere in the function
      cause = setlocale.getEnclosingFunction().getBlock()
      or
      // `errno` is not reset after a call to a function
      cause = any(FunctionCall fc2 | fc2 != setlocale)
    ) and
    msg =
      "The value of `errno` may be different than `0` when `setlocale` is called. The following `errno` check might be invalid."
    or
    //errno is checked before the return value
    check = returnNotCheckedAfter(setlocale) and
    msg = "Do not read `errno` before checking the return value of a call to `setlocale`."
  )
select setlocale, msg

/**
 * @id c/cert/errno-read-before-return
 * @name ERR30-C: Do not check errno before the function return value
 * @description Do not check errno before the function return value. Failing to do so might
 *              invalidate the error detection.
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
 * A call to an `OutOfBandErrnoSettingFunction`
 */
class OutOfBandErrnoSettingFunctionCertCall extends FunctionCall {
  OutOfBandErrnoSettingFunctionCertCall() {
    this.getTarget() instanceof OutOfBandErrnoSettingFunctionCert
  }
}

/**
 * A successor of an ErrnoSettingFunctionCertCall appearing
 * before a check of the return value
 */
ControlFlowNode returnNotCheckedAfter(OutOfBandErrnoSettingFunctionCertCall errnoSet) {
  result = errnoSet
  or
  exists(ControlFlowNode mid |
    result = mid.getASuccessor() and
    mid = returnNotCheckedAfter(errnoSet) and
    // stop recursion on a return value check
    not (
      any(ControlStructure cs).getControllingExpr() = result and
      DataFlow::localExprFlow(errnoSet, result.(Operation).getAnOperand*())
    ) and
    // stop recursion on a following errno setting function call
    not result instanceof OutOfBandErrnoSettingFunctionCertCall
  )
}

from OutOfBandErrnoSettingFunctionCertCall errnoSet, ErrnoRead check
where
  not isExcluded(check, Contracts4Package::errnoReadBeforeReturnQuery()) and
  check = returnNotCheckedAfter(errnoSet)
select check, "Do not read `errno` before checking the return value of function $@.", errnoSet,
  errnoSet.toString()

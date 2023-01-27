/**
 * @id c/cert/function-call-before-errno-check
 * @name ERR30-C: Do not call a function before checking errno
 * @description After calling an errno-setting function, check errno before calling any other
 *              function. Failing to do so might end in errno being overwritten.
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
import semmle.code.cpp.dataflow.DataFlow

/**
 * A call to an `OutOfBandErrnoSettingFunction`
 */
class ErrnoSettingFunctionCall extends FunctionCall {
  ErrnoSettingFunctionCall() { this.getTarget() instanceof InBandErrnoSettingFunction }
}

/**
 * A successor of an ErrnoSettingFunctionCall appearing
 * before a check of errno
 */
ControlFlowNode errnoNotCheckedAfter(ErrnoSettingFunctionCall errnoSet) {
  result = errnoSet
  or
  exists(ControlFlowNode mid |
    result = mid.getASuccessor() and
    mid = errnoNotCheckedAfter(errnoSet) and
    // stop recursion on an error check
    not result instanceof ErrnoRead
  )
}

from ErrnoSettingFunctionCall errnoSet, FunctionCall fc
where
  not isExcluded(fc, Contracts4Package::functionCallBeforeErrnoCheckQuery()) and
  fc != errnoSet and
  fc = errnoNotCheckedAfter(errnoSet)
select errnoSet,
  "The value of `errno` is not checked after this call to `" + errnoSet.getTarget().getName() + "`."

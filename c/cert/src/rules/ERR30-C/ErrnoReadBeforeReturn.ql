/**
 * @id c/cert/errno-read-before-return
 * @name ERR30-C: Do not check errno before the function return value.
 * @description Do not check errno before the function return value.
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

/*
 * A call to an `OutOfBandErrnoSettingFunction`
 */

class ErrnoSettingFunctionCall extends FunctionCall {
  ErrnoSettingFunctionCall() { this.getTarget() instanceof OutOfBandErrnoSettingFunctionCert }
}

class ErrnoCheck extends Expr {
  ErrnoCheck() {
    this = any(MacroInvocation ma | ma.getMacroName() = "errno").getAnExpandedElement()
    or
    this.(FunctionCall).getTarget().hasName(["perror", "strerror"])
  }
}

/*
 * A successor of an ErrnoSettingFunctionCall appearing
 * before a check of the return value
 */

ControlFlowNode returnNotCheckedAfter(ErrnoSettingFunctionCall errnoSet) {
  result = errnoSet
  or
  exists(ControlFlowNode mid |
    result = mid.getASuccessor() and
    mid = returnNotCheckedAfter(errnoSet) and
    // stop recursion on a return value check
    not (
      any(ControlStructure cs).getControllingExpr() = result and
      DataFlow::localExprFlow(errnoSet, result.(Operation).getAnOperand*())
    )
  )
}

from ErrnoSettingFunctionCall errnoSet, ErrnoCheck check
where
  not isExcluded(check, Contracts4Package::errnoReadBeforeReturnQuery()) and
  check = returnNotCheckedAfter(errnoSet)
select check, "Do not check `errno` before checking the return value of function $@.", errnoSet,
  errnoSet.toString()

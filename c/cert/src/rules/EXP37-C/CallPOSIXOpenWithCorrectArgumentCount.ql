/**
 * @id c/cert/call-posix-open-with-correct-argument-count
 * @name EXP37-C: Pass the correct number of arguments to the POSIX open function
 * @description A third argument should be passed to the POSIX function open() when and only when
 *              creating a new file.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp37-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.commons.unix.Constants
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

int o_creat_val() {
  result = any(MacroInvocation ma | ma.getMacroName() = "O_CREAT" | ma.getExpr().getValue().toInt())
  or
  result = o_creat()
}

/**
 * A function call to POSIX open()
 */
class POSIXOpenFunctionCall extends FunctionCall {
  POSIXOpenFunctionCall() { this.getTarget().getQualifiedName() = "open" }

  /**
   * Holds if reasonable bounds exist for the value of the 'flags' argument of the call.
   * This predicate will never hold for cases such as wrapper functions
   * which pass a parameter to the open() 'flags' argument.
   */
  predicate hasFlagsArgBounds() { lowerBound(this.getArgument(1)) >= 0 }

  /**
   * Holds if the 'flags' argument contains the O_CREAT flag.
   * Because this predicate uses the SimpleRangeAnalysis library, it only
   * analyzes the bounds of 'flag' arguments which can be deduced locally.
   */
  predicate isOpenCreateCall() {
    hasFlagsArgBounds() and
    upperBound(this.getArgument(1)).(int).bitAnd(o_creat_val()) != 0
  }
}

from POSIXOpenFunctionCall call, string message
where
  not isExcluded(call, ExpressionsPackage::callPOSIXOpenWithCorrectArgumentCountQuery()) and
  // include only analyzable flag arguments which have values that can be determined locally
  call.hasFlagsArgBounds() and
  // differentiate between two variants:
  // 1) a call to open() with the O_CREAT flag set, which should pass three arguments
  // 2) a call to open without the O_CREAT flag set, which should pass two arguments
  if call.isOpenCreateCall()
  then (
    call.getNumberOfArguments() != 3 and
    message =
      "Call to " + call.getTarget().getName() +
        " with O_CREAT flag does not pass exactly three arguments."
  ) else (
    call.getNumberOfArguments() != 2 and
    message =
      "Call to " + call.getTarget().getName() +
        " without O_CREAT flag does not pass exactly two arguments."
  )
select call, message

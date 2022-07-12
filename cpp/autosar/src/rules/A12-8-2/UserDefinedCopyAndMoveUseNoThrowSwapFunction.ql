/**
 * @id cpp/autosar/user-defined-copy-and-move-use-no-throw-swap-function
 * @name A12-8-2: User-defined copy and move assignment operators should use user-defined no-throw swap function
 * @description User-defined copy and move assignment operators should use a user-defined no-throw
 *              swap function.  Using a non-throw swap operation in the copy and move assignment
 *              operators helps to achieve strong exception safety and will not require a check for
 *              assignment to itself.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a12-8-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

class NoExceptFunction extends Function {
  NoExceptFunction() { this.isNoExcept() }
}

predicate callsStdSwap(Function f) {
  exists(FunctionCall fc |
    fc.getTarget().hasQualifiedName("std", "swap") and
    fc.getEnclosingFunction() = f
  )
}

predicate callsNoExceptSwap(Operator o) {
  exists(NoExceptFunction f, FunctionCall fc |
    callsStdSwap(f) and
    fc.getEnclosingFunction() = o and
    fc.getTarget() = f
  )
}

from UserCopyOrUserMoveOperator o
where
  not isExcluded(o, OperatorInvariantsPackage::userDefinedCopyAndMoveUseNoThrowSwapFunctionQuery()) and
  not callsNoExceptSwap(o)
select o, "User defined copy or move operator does not call no-except swap."

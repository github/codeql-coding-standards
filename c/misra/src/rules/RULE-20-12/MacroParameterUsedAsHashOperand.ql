/**
 * @id c/misra/macro-parameter-used-as-hash-operand
 * @name RULE-20-12: A macro parameter used as an operand to the # or ## operators shall only be used as an operand to these operators
 * @description A macro parameter used in different contexts such as: 1) an operand to the # or ##
 *              operators where it is not expanded, versus 2) elsewhere where it is expanded, makes
 *              code more difficult to understand.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-12
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Macro

from FunctionLikeMacro m, MacroInvocation mi, int i, string expanded, string param
where
  not isExcluded(mi, Preprocessor2Package::macroParameterUsedAsHashOperandQuery()) and
  mi = m.getAnInvocation() and
  param = m.getParameter(i) and
  (
    exists(TokenPastingOperator op | op.getMacro() = m and op.getOperand() = param)
    or
    exists(StringizingOperator op | op.getMacro() = m and op.getOperand() = param)
  ) and
  // An expansion that is equal to "" means the expansion is not used and is optimized away by EDG. This happens when the expanded argument is an operand to `#` or `##`.
  // This check ensure there is an expansion that is used.
  expanded = mi.getExpandedArgument(i) and
  not expanded = "" and
  not mi.getUnexpandedArgument(i) = mi.getExpandedArgument(i)
select m,
  "Macro " + m.getName() + " contains use of parameter " + param + " used in multiple contexts."

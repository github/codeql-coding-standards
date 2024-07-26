/**
 * Provides a library with a `problems` predicate for the following issue:
 * The argument to a mixed-use macro parameter shall not be subject to further
 * expansion.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Macro

abstract class AMixedUseMacroArgumentSubjectToExpansionSharedQuery extends Query { }

Query getQuery() { result instanceof AMixedUseMacroArgumentSubjectToExpansionSharedQuery }

query predicate problems(FunctionLikeMacro m, string message) {
  exists(MacroInvocation mi, int i, string expanded, string param |
    not isExcluded(m, getQuery()) and
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
    not mi.getUnexpandedArgument(i) = mi.getExpandedArgument(i) and
    message =
      "Macro " + m.getName() + " contains use of parameter " + param + " used in multiple contexts."
  )
}

/**
 * @id cpp/misra/global-variable-used
 * @name RULE-6-7-2: Global variables shall not be used
 * @description Global variables can be accessed and modified from distant and unclear points in the
 *              code, creating a risk of data races and unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-7-2
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Linkage
import codingstandards.cpp.orderofevaluation.Initialization

class GlobalVariable extends Variable {
  GlobalVariable() {
    hasNamespaceScope(this) or
    this.(MemberVariable).isStatic()
  }
}

from GlobalVariable var, string suffix, Element reasonElement, string reasonString
where
  not isExcluded(var, Banned1Package::globalVariableUsedQuery()) and
  not var.isConstexpr() and
  (
    not var.isConst() and
    suffix = "as non-const" and
    // Placeholder is not used, but they must be bound.
    reasonString = "" and
    reasonElement = var
    or
    var.isConst() and
    isNotConstantInitialized(var, reasonString, reasonElement) and
    suffix = "as const, but is not constant initialized because it $@"
  )
select var, "Global variable " + var.getName() + " declared " + suffix, reasonElement, reasonString

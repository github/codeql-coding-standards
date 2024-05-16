/**
 * @id cpp/misra/variable-declared-in-inner-scope-hides-outer-scope
 * @name RULE-6-4-1: A variable declared in an inner scope shall not hide a variable declared in an outer scope
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-4-1
 *       readability
 *       maintainability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.identifierhidden.IdentifierHidden

class VariableDeclaredInInnerScopeHidesOuterScopeQuery extends IdentifierHiddenSharedQuery {
  VariableDeclaredInInnerScopeHidesOuterScopeQuery() {
    this = ImportMisra23Package::variableDeclaredInInnerScopeHidesOuterScopeQuery()
  }
}

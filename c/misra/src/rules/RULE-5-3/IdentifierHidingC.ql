/**
 * @id c/misra/identifier-hiding-c
 * @name RULE-5-3: An identifier declared in an inner scope shall not hide an identifier declared in an outer scope
 * @description Use of an identifier declared in an inner scope with an identical name to an
 *              identifier in an outer scope can lead to inadvertent errors if the incorrect
 *              identifier is modified.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-5-3
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.identifierhidden.IdentifierHidden

class IdentifierHidingCQuery extends IdentifierHiddenSharedQuery {
  IdentifierHidingCQuery() {
    this = Declarations3Package::identifierHidingCQuery()
  }
}
